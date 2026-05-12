import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/l10n/l10n_lookup.dart';

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
    if (!['easy', 'medium', 'hard', 'very_hard'].contains(nextDifficulty)) {
      render(appL10nCurrent().statusUnknownDifficulty(difficulty));
      return;
    }
    if (!settings.state.canChangeDifficulty) {
      render(appL10nCurrent().statusDifficultyChangeBlocked);
      return;
    }
    if (!_premiumPolicyService.isDifficultyUnlocked(
      nextDifficulty,
      entitlement,
    )) {
      render(appL10nCurrent().statusDifficultyPremiumOnly);
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
    settings.setPuzzleMode('unique');
    render(appL10nCurrent().statusPuzzleModeUnique);
  }
}
