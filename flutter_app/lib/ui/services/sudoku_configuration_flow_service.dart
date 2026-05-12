import 'package:flutter/material.dart';
import 'package:flutter_app/app/difficulty_labels.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_new_game_confirmation_service.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class SudokuConfigurationFlowService {
  final SudokuNewGameConfirmationService _confirmationService;

  const SudokuConfigurationFlowService({
    SudokuNewGameConfirmationService? confirmationService,
  }) : _confirmationService =
           confirmationService ?? const SudokuNewGameConfirmationService();

  String lockedSettingsMessage(BuildContext context) {
    return UiStrings.lockedSettingsMessage(context);
  }

  Future<void> requestUnlockByStartingNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required VoidCallback onConfirmNewGame,
  }) async {
    if (state.canChangeDifficulty) {
      return;
    }
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: UiStrings.dialogUnlockSettingsTitle(context),
      message: UiStrings.dialogUnlockSettingsMessage(context),
      onConfirm: onConfirmNewGame,
    );
  }

  Future<void> requestPuzzleModeChange({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required String mode,
    required ValueChanged<String> onConfirmChange,
  }) async {
    onConfirmChange('unique');
  }

  Future<void> requestDifficultyChange({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required String difficulty,
    required ValueChanged<String> onConfirmChange,
  }) async {
    if (difficulty == state.difficulty) {
      return;
    }
    if (state.gameOver) {
      onConfirmChange(difficulty);
      return;
    }
    final difficultyLabel = difficultyDisplayLabel(difficulty);
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: UiStrings.dialogStartNewGameTitle(context),
      message: UiStrings.dialogStartNewGameForDifficulty(
        context,
        difficultyLabel,
      ),
      onConfirm: () => onConfirmChange(difficulty),
    );
  }

  Future<void> requestNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required bool isCurrentGameResumed,
    required VoidCallback onConfirmNewGame,
    VoidCallback? onConfirmed,
  }) async {
    final shouldRequireConfirmation =
        !state.gameOver && (isCurrentGameResumed || state.canUndo);
    if (!shouldRequireConfirmation) {
      onConfirmNewGame();
      onConfirmed?.call();
      return;
    }
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: UiStrings.dialogStartNewGameTitle(context),
      message: UiStrings.dialogStartNewGameResetBoard(context),
      onConfirm: () {
        onConfirmNewGame();
        onConfirmed?.call();
      },
    );
  }
}
