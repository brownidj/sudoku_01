import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuGameplayActionService {
  final GameService _gameService;
  final ContradictionService _contradictionService;
  final CorrectionRecoveryService _correctionRecoveryService;
  final SudokuRuntimeStateService _runtimeStateService;

  const SudokuGameplayActionService({
    required GameService gameService,
    required ContradictionService contradictionService,
    required CorrectionRecoveryService correctionRecoveryService,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _gameService = gameService,
       _contradictionService = contradictionService,
       _correctionRecoveryService = correctionRecoveryService,
       _runtimeStateService = runtimeStateService;

  void applyBoardEditOutcome({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required BoardEditOutcome outcome,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    if (outcome.statusMessage != null) {
      render(outcome.statusMessage!);
      return;
    }
    final result = outcome.result;
    if (result == null) {
      return;
    }

    final boardChanged =
        result.history.present.board != runtime.history.present.board;
    applyPlayerResult(
      runtime: runtime,
      result: result,
      boardChanged: boardChanged,
      saveGameSession: saveGameSession,
      render: render,
    );
    var locksChanged = false;
    if (outcome.lockDifficulty) {
      settings.setDifficultyLocked(true);
      locksChanged = true;
    }
    if (outcome.lockPuzzleMode) {
      settings.setPuzzleModeLocked(true);
      locksChanged = true;
    }
    if (locksChanged) {
      // Persist lock state for unfinished sessions so resume shows the same UI.
      saveGameSession();
    }
  }

  void applyResult({
    required SudokuRuntimeState runtime,
    required MoveResult result,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
    String? statusOverride,
  }) {
    runtime
      ..history = result.history
      ..lastConflicts = result.conflicts;
    saveGameSession();
    render(statusOverride ?? result.message);
  }

  void applyPlayerResult({
    required SudokuRuntimeState runtime,
    required MoveResult result,
    required bool boardChanged,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    final nextMoveId = boardChanged
        ? runtime.correctionState.currentMoveId + 1
        : runtime.correctionState.currentMoveId;
    runtime.history = result.history;

    final analysis = _contradictionService.analyze(
      runtime.history.present.board,
    );
    if (result.conflicts.isNotEmpty) {
      runtime.lastConflicts = _resolveConflictsForDisplay(
        runtime: runtime,
        conflicts: result.conflicts,
      );
    } else if (analysis.hasContradiction) {
      runtime.lastConflicts = analysis.contradictionCells;
    } else {
      runtime.lastConflicts = const <Coord>{};
    }

    var nextCorrection = runtime.correctionState.copyWith(
      currentMoveId: nextMoveId,
      pendingPromptCoord: null,
      revertedCells: boardChanged
          ? const {}
          : runtime.correctionState.revertedCells,
    );

    if (boardChanged && !analysis.hasContradiction) {
      final checkpoints = nextCorrection.prunedToMoveId(
        runtime.correctionState.currentMoveId,
      );
      nextCorrection = nextCorrection.copyWith(
        checkpoints: [
          ...checkpoints,
          CorrectionCheckpoint(history: runtime.history, moveId: nextMoveId),
        ],
      );
    }

    runtime.correctionState = nextCorrection;
    if (boardChanged) {
      runtime.correctionNoticeMessage = null;
    }
    if (result.solved) {
      runtime
        ..gameOver = true
        ..puzzleSolved = true
        ..selected = null;
      _runtimeStateService.clearCorrectionPromptState(
        runtime,
        clearRevertedCells: true,
      );
    }
    saveGameSession();

    if (analysis.hasContradiction && runtime.correctionState.tokensLeft == 0) {
      render('Contradiction detected. Use Undo to recover.');
      return;
    }
    render(result.message);
  }

  Set<Coord> _resolveConflictsForDisplay({
    required SudokuRuntimeState runtime,
    required Set<Coord> conflicts,
  }) {
    if (conflicts.isEmpty) {
      return const <Coord>{};
    }

    if (conflicts.length <= 1) {
      return conflicts;
    }

    if (runtime.conflictHintsLeft > 0) {
      runtime.conflictHintsLeft -= 1;
      return conflicts;
    }

    final selected = runtime.selected;
    if (selected != null && conflicts.contains(selected)) {
      return <Coord>{selected};
    }
    return <Coord>{conflicts.first};
  }

  void startPuzzle({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    final puzzle = puzzles.generatePuzzle(
      settings.state.difficulty,
      mode: settings.state.puzzleMode,
    );
    final result = _gameService.newGameFromGrid(puzzle.grid);
    _runtimeStateService.resetBoardFlags(runtime, settings);
    runtime.initialGrid = List<List<Digit?>>.generate(9, (r) {
      return List<Digit?>.generate(
        9,
        (col) => puzzle.grid[r][col],
        growable: false,
      );
    }, growable: false);
    applyResult(
      runtime: runtime,
      result: result,
      saveGameSession: saveGameSession,
      render: render,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
    runtime
      ..correctionState = _runtimeStateService.initialCorrectionState(
        difficulty: puzzle.difficulty,
        history: runtime.history,
      )
      ..debugScenarioLabel = null;
    saveGameSession();
  }

  void queueCorrectionPromptForSelection({
    required SudokuRuntimeState runtime,
    required Coord coord,
  }) {
    runtime.correctionState = _correctionRecoveryService
        .queuePromptForSelection(
          history: runtime.history,
          correctionState: runtime.correctionState,
          coord: coord,
        );
  }
}
