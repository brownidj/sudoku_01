import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/domain/types.dart';

class GameConfigurationService {
  final PremiumPolicyService _premiumPolicyService;

  const GameConfigurationService({
    PremiumPolicyService premiumPolicyService = const PremiumPolicyService(),
  }) : _premiumPolicyService = premiumPolicyService;

  void setDifficulty({
    required SettingsController settings,
    required Entitlement entitlement,
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
    if (!_premiumPolicyService.isDifficultyUnlocked(nextDifficulty, entitlement)) {
      render('This difficulty is available in Premium.');
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
