import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';

class SudokuResolutionActionService {
  final SolutionCheckCoordinator _solutionCoordinator;
  final CorrectionRecoveryService _correctionRecoveryService;
  final SudokuRuntimeStateService _runtimeStateService;

  const SudokuResolutionActionService({
    required SolutionCheckCoordinator solutionCoordinator,
    required CorrectionRecoveryService correctionRecoveryService,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _solutionCoordinator = solutionCoordinator,
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
      initialGrid: runtime.initialGrid,
    );
    runtime
      ..history = result.history
      ..lastConflicts = result.conflicts
      ..correctionState = result.correctionState;
    if (result.correctedTiles > 0) {
      runtime
        ..correctionNoticeSerial = runtime.correctionNoticeSerial + 1
        ..correctionNoticeMessage =
            '${result.correctedTiles} tile(s) corrected.';
    }
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
}
