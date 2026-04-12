import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/settings_controller.dart';

class GameConfigurationService {
  const GameConfigurationService();

  void setDifficulty({
    required SettingsController settings,
    required String difficulty,
    required VoidCallback startGame,
    required ValueChanged<String> render,
  }) {
    final nextDifficulty = difficulty.trim().toLowerCase();
    if (!['easy', 'medium', 'hard'].contains(nextDifficulty)) {
      render('Unknown difficulty: $difficulty');
      return;
    }
    if (!settings.state.canChangeDifficulty) {
      render('Finish or start a new game before changing difficulty');
      return;
    }
    if (!settings.setDifficulty(nextDifficulty)) {
      return;
    }
    settings.setPuzzleMode('unique');
    startGame();
  }

  void setPuzzleMode({
    required SettingsController settings,
    required String mode,
    required VoidCallback startGame,
    required ValueChanged<String> render,
  }) {
    if (!settings.state.canChangePuzzleMode) {
      render('Finish or check the game before changing puzzle mode');
      return;
    }
    if (settings.state.difficulty == 'hard') {
      settings.setPuzzleMode('unique');
      render('Puzzle mode: unique');
      return;
    }
    settings.setPuzzleMode(mode == 'unique' ? 'unique' : 'multi');
    startGame();
  }
}
