import 'package:flutter/foundation.dart';

class MonetizationConfig {
  static const String premiumUnlockAndroid = 'premium_unlock';
  static const String premiumUnlockIos = 'premium_unlock';

  static Set<String> get productIds => {
    premiumUnlockAndroid,
    premiumUnlockIos,
  };

  static String premiumUnlockIdForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
        return premiumUnlockAndroid;
      case TargetPlatform.iOS:
        return premiumUnlockIos;
      default:
        return '';
    }
  }

  static String premiumUnlockIdForCurrentPlatform() {
    return premiumUnlockIdForPlatform(defaultTargetPlatform);
  }

  static bool isPremiumUnlockConfigured(TargetPlatform platform) {
    return premiumUnlockIdForPlatform(platform).trim().isNotEmpty;
  }
}
