import 'package:flutter_app/app/app_debug.dart';
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

  static const Set<String> freeContentModes = <String>{
    'animals',
    'instruments',
    'numbers',
  };

  static const Set<String> premiumContentModes = <String>{
    'butterflies',
    'shells',
    'old_opera',
  };

  bool isUnlocked(PremiumFeature feature, Entitlement entitlement) {
    final unlocked = _unlockedByEntitlement[entitlement] ?? const {};
    final allowed = unlocked.contains(feature);
    AppDebug.log(
      '[PremiumPolicy] feature=$feature entitlement=$entitlement allowed=$allowed',
    );
    return allowed;
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
      return 'Full Version Feature';
    }
    return labelForFeature(feature);
  }

  bool isDifficultyUnlocked(String difficulty, Entitlement entitlement) {
    final feature = featureForDifficulty(difficulty);
    if (feature == null) {
      AppDebug.log(
        '[PremiumPolicy] difficulty=$difficulty entitlement=$entitlement allowed=true',
      );
      return true;
    }
    final allowed = isUnlocked(feature, entitlement);
    AppDebug.log(
      '[PremiumPolicy] difficulty=$difficulty entitlement=$entitlement allowed=$allowed',
    );
    return allowed;
  }

  bool isPremiumActive(Entitlement entitlement) {
    final unlocked = _unlockedByEntitlement[entitlement] ?? const {};
    final active = unlocked.isNotEmpty;
    AppDebug.log(
      '[PremiumPolicy] premiumActive entitlement=$entitlement active=$active',
    );
    return active;
  }

  bool isContentModeUnlocked(String contentMode, Entitlement entitlement) {
    final mode = contentMode.trim().toLowerCase();
    if (freeContentModes.contains(mode)) {
      AppDebug.log(
        '[PremiumPolicy] contentMode=$mode entitlement=$entitlement allowed=true',
      );
      return true;
    }
    if (premiumContentModes.contains(mode)) {
      final allowed = isUnlocked(PremiumFeature.extraThemes, entitlement);
      AppDebug.log(
        '[PremiumPolicy] contentMode=$mode entitlement=$entitlement allowed=$allowed',
      );
      return allowed;
    }
    AppDebug.log(
      '[PremiumPolicy] contentMode=$mode entitlement=$entitlement allowed=false (unknown)',
    );
    return false;
  }

  bool isBackgroundMusicThemeMode(String contentMode) {
    final mode = contentMode.trim().toLowerCase();
    return premiumContentModes.contains(mode);
  }

  bool areEnhancedCelebrationsUnlocked(Entitlement entitlement) {
    return isUnlocked(PremiumFeature.extraSoundsAndCelebrations, entitlement);
  }

  bool areExtendedMetricsUnlocked(Entitlement entitlement) {
    return isUnlocked(PremiumFeature.progressTracker, entitlement);
  }

  bool isPersonalBestUnlocked(Entitlement entitlement) {
    return isUnlocked(PremiumFeature.personalBestHistory, entitlement);
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
