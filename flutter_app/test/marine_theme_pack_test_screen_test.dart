import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/debug/marine_theme_pack_test_screen.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'unsupported setup keeps network actions disabled and explains free pilot',
    (tester) async {
      final delivery = _UnsupportedDelivery();
      final pilot = _UnsupportedPilot(delivery);
      await tester.pumpWidget(
        MaterialApp(
          home: MarineThemePackTestScreen(createPilot: () async => pilot),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No Full Version unlock needed'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Apple delivery requires iOS 26+'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Fetch catalogue'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Download and install'),
            )
            .onPressed,
        isNull,
      );
      expect(delivery.downloadRequests, 0);

      await tester.tap(find.text('Verify offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('No Marine Life installation was found.'),
        findsOneWidget,
      );
      expect(delivery.downloadRequests, 0);
    },
  );
}

class _UnsupportedPilot extends MarineThemePackPilot {
  _UnsupportedPilot(AppleThemePackDelivery delivery)
    : super(
        delivery: delivery,
        storagePaths: ThemeStoragePaths(Directory('/unused-test-path')),
        appBuild: 359,
      );

  @override
  Future<MarinePilotDescriptor?> cachedCatalogue() async => null;

  @override
  Future<ThemeDefinition?> loadInstalled() async => null;
}

class _UnsupportedDelivery extends AppleThemePackDelivery {
  int downloadRequests = 0;

  @override
  Stream<AppleThemePackProgress> get progress => const Stream.empty();

  @override
  Future<AppleThemePackConfiguration> getConfiguration() async =>
      const AppleThemePackConfiguration(supported: false, configured: false);

  @override
  Future<String> ensureAvailable({
    required String assetPackId,
    required String relativePath,
  }) async {
    downloadRequests++;
    throw StateError('Unsupported delivery must never be called.');
  }
}
