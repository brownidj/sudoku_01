import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/debug_scenarios.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/game_service.dart';

class GameScenarioService {
  final GameService _gameService;
  final ContradictionService _contradictionService;
  final SudokuRuntimeStateService _runtimeStateService;

  const GameScenarioService({
    required GameService gameService,
    required ContradictionService contradictionService,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _gameService = gameService,
       _contradictionService = contradictionService,
       _runtimeStateService = runtimeStateService;

  void loadCorrectionScenario({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    final scenario = DebugScenarios.correctionRecovery(
      service: _gameService,
      currentSettings: settings.state,
      tokensLeft:
          runtime.debugScenarioLabel == 'Debug scenario: correction available'
          ? runtime.correctionState.tokensLeft
          : null,
    );
    _applyDebugScenario(
      runtime: runtime,
      settings: settings,
      scenario: scenario,
      saveGameSession: saveGameSession,
      render: render,
      status: 'Debug correction scenario loaded',
    );
  }

  void loadExhaustedCorrectionScenario({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    final scenario = DebugScenarios.exhaustedCorrectionRecovery(
      service: _gameService,
      currentSettings: settings.state,
    );
    _applyDebugScenario(
      runtime: runtime,
      settings: settings,
      scenario: scenario,
      saveGameSession: saveGameSession,
      render: render,
      status: 'Debug exhausted-corrections scenario loaded',
    );
  }

  void undo({
    required SudokuRuntimeState runtime,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    if (runtime.gameOver) {
      return;
    }
    final result = _gameService.undo(runtime.history);
    if (result.history == runtime.history) {
      render(result.message);
      return;
    }

    final nextMoveId = runtime.correctionState.currentMoveId > 0
        ? runtime.correctionState.currentMoveId - 1
        : 0;
    runtime.history = result.history;
    runtime.lastConflicts = _contradictionService
        .analyze(runtime.history.present.board)
        .contradictionCells;
    runtime.correctionState = runtime.correctionState.copyWith(
      currentMoveId: nextMoveId,
      checkpoints: runtime.correctionState.prunedToMoveId(nextMoveId),
      revertedCells: const {},
      pendingPromptCoord: null,
    );
    saveGameSession();
    render(result.message);
  }

  void _applyDebugScenario({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required DebugScenario scenario,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
    required String status,
  }) {
    runtime
      ..debugScenarioLabel = scenario.label
      ..history = scenario.history
      ..correctionState = scenario.correctionState
      ..selected = scenario.selected
      ..initialGrid = scenario.initialGrid
      ..lastConflicts = _contradictionService
          .analyze(scenario.history.present.board)
          .contradictionCells
      ..incorrectCells = {}
      ..solutionAddedCells = {}
      ..correctCells = {}
      ..solutionGrid = null
      ..gameOver = false
      ..puzzleSolved = false
      ..correctionNoticeMessage = null;
    _runtimeStateService.applyRestoredSettings(settings, scenario.settings);
    saveGameSession();
    render(status);
  }
}
