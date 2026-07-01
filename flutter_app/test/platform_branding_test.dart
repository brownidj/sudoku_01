import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iOS runtime branding uses SuDoKu Playtime', (tester) async {
    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                Text(UiStrings.launchTitle(context)),
                Text(UiStrings.drawerTitle(context)),
              ],
            ),
          ),
        ),
      );

      expect(find.text('SuDoKu Playtime'), findsNWidgets(2));
      expect(find.text('SuDoKu Fresh'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Android runtime branding uses SuDoKu Fresh', (tester) async {
    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                Text(UiStrings.launchTitle(context)),
                Text(UiStrings.drawerTitle(context)),
              ],
            ),
          ),
        ),
      );

      expect(find.text('SuDoKu Fresh'), findsNWidgets(2));
      expect(find.text('SuDoKu Playtime'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('iOS bundle display name remains SuDoKu Playtime', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      infoPlist,
      contains(
        '<key>CFBundleDisplayName</key>\n\t<string>SuDoKu Playtime</string>',
      ),
    );
    expect(
      infoPlist,
      contains('<key>CFBundleName</key>\n\t<string>SuDoKu Playtime</string>'),
    );
  });

  test('Android app label remains SuDoKu Fresh', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:label="SuDoKu Fresh"'));
  });

  test('App Store screenshot script forces iOS branding', () {
    final script = File(
      'scripts/capture_app_store_screenshots.sh',
    ).readAsStringSync();
    expect(script, contains('--dart-define=SCREENSHOT_BRAND_PLATFORM=ios'));
  });

  test('Play Store screenshot script forces Android branding', () {
    final script = File(
      'scripts/capture_play_store_screenshots.sh',
    ).readAsStringSync();
    expect(script, contains('--dart-define=SCREENSHOT_BRAND_PLATFORM=android'));
  });
}
