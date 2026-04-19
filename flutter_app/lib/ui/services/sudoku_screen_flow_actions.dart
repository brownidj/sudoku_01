import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/sudoku_configuration_flow_service.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';

class SudokuScreenFlowActions {
  final SudokuConfigurationFlowService _configurationFlowService;

  const SudokuScreenFlowActions({
    SudokuConfigurationFlowService configurationFlowService =
        const SudokuConfigurationFlowService(),
  }) : _configurationFlowService = configurationFlowService;

  Future<void> requestNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
  }) {
    return _configurationFlowService.requestNewGame(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      isCurrentGameResumed: false,
      onConfirmNewGame: controller.onNewGame,
    );
  }

  Future<void> showProgressSheet({
    required BuildContext context,
    required int completedPuzzles,
  }) {
    return showInfoSheet(
      context: context,
      title: 'Your Progress',
      message:
          'Completed puzzles: $completedPuzzles\n'
          'Days played: coming soon\n'
          'Streak: coming soon',
    );
  }

  Future<void> showLockedSettingsSheet({
    required BuildContext context,
    required SudokuController controller,
  }) {
    final message = _configurationFlowService.lockedSettingsMessage(
      controller.state,
    );
    return showInfoSheet(
      context: context,
      title: 'Board Settings Locked',
      message: message,
    );
  }

  Future<void> requestUnlockByStartingNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
  }) {
    return _configurationFlowService.requestUnlockByStartingNewGame(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      onConfirmNewGame: controller.onNewGame,
    );
  }

  Future<void> requestPuzzleModeChange({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
    required String mode,
  }) {
    return _configurationFlowService.requestPuzzleModeChange(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      mode: mode,
      onConfirmChange: controller.onPuzzleModeChanged,
    );
  }

  Future<void> requestDifficultyChange({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
    required String difficulty,
  }) {
    return _configurationFlowService.requestDifficultyChange(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      difficulty: difficulty,
      onConfirmChange: controller.onSetDifficulty,
    );
  }
}
