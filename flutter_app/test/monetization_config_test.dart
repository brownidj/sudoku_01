import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/monetization_config.dart';

void main() {
  test('uses platform-specific premium unlock IDs', () {
    expect(
      MonetizationConfig.premiumUnlockIdForPlatform(TargetPlatform.android),
      'full_unlock',
    );
    expect(
      MonetizationConfig.premiumUnlockIdForPlatform(TargetPlatform.iOS),
      'premium_unlock',
    );
  });
}
