import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/sudoku_gameplay_action_service.dart';
import 'package:flutter_app/app/sudoku_resolution_action_service.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuControllerActionService {
  final SudokuGameplayActionService _gameplayActions;
  final SudokuResolutionActionService _resolutionActions;

  SudokuControllerActionService({
    required GameService gameService,
    required SolutionCheckCoordinator solutionCoordinator,
    required ContradictionService contradictionService,
    required CorrectionRecoveryService correctionRecoveryService,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _gameplayActions = SudokuGameplayActionService(
         gameService: gameService,
         contradictionService: contradictionService,
         correctionRecoveryService: correctionRecoveryService,
         runtimeStateService: runtimeStateService,
       ),
       _resolutionActions = SudokuResolutionActionService(
         solutionCoordinator: solutionCoordinator,
         correctionRecoveryService: correctionRecoveryService,
         runtimeStateService: runtimeStateService,
       );

  void checkSolution({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _resolutionActions.checkSolution(
      runtime: runtime,
      settings: settings,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void showSolution({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _resolutionActions.showSolution(
      runtime: runtime,
      settings: settings,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void completePuzzleWithSolution({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _resolutionActions.completePuzzleWithSolution(
      runtime: runtime,
      settings: settings,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void confirmCorrection({
    required SudokuRuntimeState runtime,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _resolutionActions.confirmCorrection(
      runtime: runtime,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void dismissCorrectionPrompt({
    required SudokuRuntimeState runtime,
    required VoidCallback saveGameSession,
    required VoidCallback notifyListeners,
  }) {
    _resolutionActions.dismissCorrectionPrompt(
      runtime: runtime,
      saveGameSession: saveGameSession,
      notifyListeners: notifyListeners,
    );
  }

  void applyBoardEditOutcome({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required BoardEditOutcome outcome,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _gameplayActions.applyBoardEditOutcome(
      runtime: runtime,
      settings: settings,
      outcome: outcome,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void applyResult({
    required SudokuRuntimeState runtime,
    required MoveResult result,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
    String? statusOverride,
  }) {
    _gameplayActions.applyResult(
      runtime: runtime,
      result: result,
      saveGameSession: saveGameSession,
      render: render,
      statusOverride: statusOverride,
    );
  }

  void applyPlayerResult({
    required SudokuRuntimeState runtime,
    required MoveResult result,
    required bool boardChanged,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _gameplayActions.applyPlayerResult(
      runtime: runtime,
      result: result,
      boardChanged: boardChanged,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void startPuzzle({
    required SudokuRuntimeState runtime,
    required SettingsController settings,
    required VoidCallback saveGameSession,
    required ValueChanged<String> render,
  }) {
    _gameplayActions.startPuzzle(
      runtime: runtime,
      settings: settings,
      saveGameSession: saveGameSession,
      render: render,
    );
  }

  void queueCorrectionPromptForSelection({
    required SudokuRuntimeState runtime,
    required Coord coord,
  }) {
    _gameplayActions.queueCorrectionPromptForSelection(
      runtime: runtime,
      coord: coord,
    );
  }
}
