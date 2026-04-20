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
