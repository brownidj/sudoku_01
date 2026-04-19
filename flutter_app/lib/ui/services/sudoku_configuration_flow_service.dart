import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_new_game_confirmation_service.dart';

class SudokuConfigurationFlowService {
  final SudokuNewGameConfirmationService _confirmationService;

  const SudokuConfigurationFlowService({
    SudokuNewGameConfirmationService? confirmationService,
  }) : _confirmationService =
           confirmationService ?? const SudokuNewGameConfirmationService();

  String lockedSettingsMessage(UiState state) {
    return "Difficulty and puzzle mode are locked during a game. To unlock them, either double-tap the lock icon or start a 'New Game'";
  }

  Future<void> requestUnlockByStartingNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required VoidCallback onConfirmNewGame,
  }) async {
    if (state.canChangeDifficulty && state.canChangePuzzleMode) {
      return;
    }
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: 'Unlock Settings?',
      message:
          "Unlocking difficulty and puzzle mode will start a new game and reset this board. Continue?",
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
    if (mode == state.puzzleMode) {
      return;
    }
    if (state.gameOver) {
      onConfirmChange(mode);
      return;
    }
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: 'Start New Game?',
      message:
          'Change puzzle mode to ${mode.toUpperCase()} and start a new game?',
      onConfirm: () => onConfirmChange(mode),
    );
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
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: 'Start New Game?',
      message:
          'Change difficulty to ${difficulty.toUpperCase()} and start a new game?',
      onConfirm: () => onConfirmChange(difficulty),
    );
  }

  Future<void> requestNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required UiState state,
    required bool isCurrentGameResumed,
    required VoidCallback onConfirmNewGame,
  }) async {
    final shouldRequireConfirmation =
        !state.gameOver && (isCurrentGameResumed || state.canUndo);
    if (!shouldRequireConfirmation) {
      onConfirmNewGame();
      return;
    }
    await _confirmationService.confirmAndRun(
      context: context,
      isMounted: isMounted,
      title: 'Start New Game?',
      message: 'Start a fresh game and reset this board?',
      onConfirm: onConfirmNewGame,
    );
  }
}
