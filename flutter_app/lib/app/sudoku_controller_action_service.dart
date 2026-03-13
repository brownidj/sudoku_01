import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuControllerActionService {
  final GameService _gameService;
  final SolutionCheckCoordinator _solutionCoordinator;
  final ContradictionService _contradictionService;
  final CorrectionRecoveryService _correctionRecoveryService;
  final SudokuRuntimeStateService _runtimeStateService;

  const SudokuControllerActionService({
    required GameService gameService,
    required SolutionCheckCoordinator solutionCoordinator,
    required ContradictionService contradictionService,
    required CorrectionRecoveryService correctionRecoveryService,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _gameService = gameService,
       _solutionCoordinator = solutionCoordinator,
       _contradictionService = contradictionService,
       _correctionRecoveryService = correctionRecoveryService,
       _runtimeStateService = runtimeStateService;

  void checkSolution({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    if (runtime.gameOver) {
      return;
    }
    final result = _solutionCoordinator.check(
      history: runtime.history,
      initialGrid: runtime.initialGrid,
      givens: _runtimeStateService.givenCoords(runtime.history),
    );
    runtime
      ..incorrectCells = result.incorrect
      ..correctCells = result.correct
      ..solutionGrid = null
      ..solutionAddedCells = {}
      ..selected = null
      ..gameOver = true;
    settings.setPuzzleModeLocked(false);
    _runtimeStateService.clearCorrectionPromptState(
      runtime,
      clearRevertedCells: true,
    );
    saveGameSession();
    render('Check complete');
  }

  void showSolution({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    if (!runtime.gameOver) {
      checkSolution(
        runtime: runtime,
        settings: settings,
        saveGameSession: saveGameSession,
        render: render,
      );
    }
    if (!runtime.gameOver) {
      return;
    }
    final result = _solutionCoordinator.showSolution(
      history: runtime.history,
      initialGrid: runtime.initialGrid,
      givens: _runtimeStateService.givenCoords(runtime.history),
    );
    runtime
      ..incorrectCells = result.incorrect
      ..correctCells = result.correct
      ..solutionGrid = result.solutionGrid
      ..solutionAddedCells = result.solutionAdded
      ..selected = null;
    settings.setPuzzleModeLocked(false);
    _runtimeStateService.clearCorrectionPromptState(
      runtime,
      clearRevertedCells: true,
    );
    saveGameSession();
    render('Solution');
  }

  void confirmCorrection({
    required SudokuRuntimeState runtime,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    if (runtime.correctionState.pendingPromptCoord == null ||
        runtime.correctionState.tokensLeft <= 0) {
      return;
    }
    final result = _correctionRecoveryService.confirmCorrection(
      history: runtime.history,
      correctionState: runtime.correctionState,
    );
    runtime
      ..history = result.history
      ..lastConflicts = result.conflicts
      ..correctionState = result.correctionState;
    saveGameSession();
    render(result.status);
  }

  void dismissCorrectionPrompt({
    required SudokuRuntimeState runtime,
    required VoidCallback saveGameSession,
    required VoidCallback notifyListeners,
  }) {
    if (runtime.correctionState.pendingPromptCoord == null) {
      return;
    }
    _runtimeStateService.clearCorrectionPromptState(
      runtime,
      clearRevertedCells: false,
    );
    saveGameSession();
    notifyListeners();
  }

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
    if (outcome.lockDifficulty) {
      settings.setDifficultyLocked(true);
    }
    if (outcome.lockPuzzleMode) {
      settings.setPuzzleModeLocked(true);
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
    runtime.lastConflicts = analysis.hasContradiction
        ? analysis.contradictionCells
        : result.conflicts;

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
    saveGameSession();

    if (analysis.hasContradiction && runtime.correctionState.tokensLeft == 0) {
      render('Contradiction detected. Use Undo to recover.');
      return;
    }
    render(result.message);
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
