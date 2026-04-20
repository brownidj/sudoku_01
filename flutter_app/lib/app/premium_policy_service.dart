import 'package:flutter_app/domain/types.dart';

class PremiumPolicyService {
  const PremiumPolicyService();

  static const Map<Entitlement, Set<PremiumFeature>> _unlockedByEntitlement = {
    Entitlement.free: {},
    Entitlement.premium: {
      PremiumFeature.hardDifficulty,
      PremiumFeature.veryHardDifficulty,
      PremiumFeature.progressTracker,
      PremiumFeature.personalBestHistory,
      PremiumFeature.extraThemes,
      PremiumFeature.extraSoundsAndCelebrations,
    },
  };

  bool isUnlocked(PremiumFeature feature, Entitlement entitlement) {
    final unlocked = _unlockedByEntitlement[entitlement] ?? const {};
    return unlocked.contains(feature);
  }

  PremiumFeature? featureForDifficulty(String difficulty) {
    switch (difficulty.trim().toLowerCase()) {
      case 'hard':
        return PremiumFeature.hardDifficulty;
      case 'very_hard':
        return PremiumFeature.veryHardDifficulty;
      default:
        return null;
    }
  }

  PremiumFeature? featureForKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'hard_difficulty':
        return PremiumFeature.hardDifficulty;
      case 'very_hard_difficulty':
        return PremiumFeature.veryHardDifficulty;
      case 'progress_tracker':
        return PremiumFeature.progressTracker;
      case 'personal_best_history':
        return PremiumFeature.personalBestHistory;
      case 'extra_themes':
        return PremiumFeature.extraThemes;
      case 'extra_sounds_and_celebrations':
        return PremiumFeature.extraSoundsAndCelebrations;
      default:
        return null;
    }
  }

  String labelForFeature(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.hardDifficulty:
        return 'MUCH HARDER';
      case PremiumFeature.veryHardDifficulty:
        return 'NIGH IMPOSSIBLE';
      case PremiumFeature.progressTracker:
        return 'Progress Tracker';
      case PremiumFeature.personalBestHistory:
        return 'Personal Best History';
      case PremiumFeature.extraThemes:
        return 'Extra Themes';
      case PremiumFeature.extraSoundsAndCelebrations:
        return 'Extra Sounds and Celebrations';
    }
  }

  String labelForFeatureKey(String key) {
    final feature = featureForKey(key);
    if (feature == null) {
      return 'Premium Feature';
    }
    return labelForFeature(feature);
  }

  bool isDifficultyUnlocked(String difficulty, Entitlement entitlement) {
    final feature = featureForDifficulty(difficulty);
    if (feature == null) {
      return true;
    }
    return isUnlocked(feature, entitlement);
  }

  bool isPremiumActive(Entitlement entitlement) {
    final unlocked = _unlockedByEntitlement[entitlement] ?? const {};
    return unlocked.isNotEmpty;
  }

  Set<PremiumFeature> lockedFeatures(
    Iterable<PremiumFeature> features,
    Entitlement entitlement,
  ) {
    return features
        .where((feature) => !isUnlocked(feature, entitlement))
        .toSet();
  }
}
