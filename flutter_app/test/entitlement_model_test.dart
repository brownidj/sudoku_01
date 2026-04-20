import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/domain/types.dart';

void main() {
  group('Entitlement', () {
    test('defines free and premium tiers', () {
      expect(Entitlement.values, [Entitlement.free, Entitlement.premium]);
    });
  });

  group('PremiumFeature', () {
    test('defines premium-gated feature set', () {
      expect(
        PremiumFeature.values,
        [
          PremiumFeature.hardDifficulty,
          PremiumFeature.veryHardDifficulty,
          PremiumFeature.progressTracker,
          PremiumFeature.personalBestHistory,
          PremiumFeature.extraThemes,
          PremiumFeature.extraSoundsAndCelebrations,
        ],
      );
    });
  });
}
