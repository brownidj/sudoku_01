import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PremiumPolicyService', () {
    const service = PremiumPolicyService();

    test('free entitlement cannot access premium features', () {
      for (final feature in PremiumFeature.values) {
        expect(service.isUnlocked(feature, Entitlement.free), isFalse);
      }
    });

    test('premium entitlement can access all premium features', () {
      for (final feature in PremiumFeature.values) {
        expect(service.isUnlocked(feature, Entitlement.premium), isTrue);
      }
    });

    test('isPremiumActive reflects entitlement state', () {
      expect(service.isPremiumActive(Entitlement.free), isFalse);
      expect(service.isPremiumActive(Entitlement.premium), isTrue);
    });

    test('lockedFeatures returns only denied features', () {
      final features = PremiumFeature.values;
      expect(service.lockedFeatures(features, Entitlement.free), features.toSet());
      expect(service.lockedFeatures(features, Entitlement.premium), isEmpty);
    });

    test('difficulty checks map through premium feature policy', () {
      expect(service.isDifficultyUnlocked('easy', Entitlement.free), isTrue);
      expect(service.isDifficultyUnlocked('medium', Entitlement.free), isTrue);
      expect(service.isDifficultyUnlocked('hard', Entitlement.free), isFalse);
      expect(service.isDifficultyUnlocked('hard', Entitlement.premium), isTrue);
      expect(
        service.isDifficultyUnlocked('very_hard', Entitlement.free),
        isFalse,
      );
      expect(
        service.isDifficultyUnlocked('very_hard', Entitlement.premium),
        isTrue,
      );
    });
  });
}
