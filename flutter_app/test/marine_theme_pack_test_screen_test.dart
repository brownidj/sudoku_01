import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/debug/marine_theme_pack_test_screen.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, _InteractivePilot pilot) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MarineThemePackTestScreen(createPilot: () async => pilot),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool installEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Download and install'),
          )
          .onPressed !=
      null;

  testWidgets(
    'catalogue gates installation and pending downloads cannot repeat',
    (tester) async {
      final pilot = _InteractivePilot();
      await open(tester, pilot);
      expect(installEnabled(tester), isFalse);
      await tester.tap(find.text('Fetch catalogue'));
      await tester.pumpAndSettle();
      expect(installEnabled(tester), isTrue);

      await tester.tap(find.text('Download and install'));
      await tester.pump();
      expect(installEnabled(tester), isFalse);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(pilot.installCalls, 1);

      pilot.pending.complete(_installedTheme);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('v2 is installed and verified'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets('failed installation reports error and allows retry', (
    tester,
  ) async {
    final pilot = _InteractivePilot();
    await open(tester, pilot);
    await tester.tap(find.text('Fetch catalogue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download and install'));
    await tester.pump();
    pilot.pending.completeError(
      const MarinePilotException('Checksum mismatch'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Checksum mismatch'), findsOneWidget);
    expect(installEnabled(tester), isTrue);
    pilot.pending = Completer<ThemeDefinition>();
    await tester.tap(find.text('Download and install'));
    await tester.pump();
    pilot.pending.complete(_installedTheme);
    await tester.pumpAndSettle();
    expect(pilot.installCalls, 2);
    expect(find.textContaining('v2 is installed and verified'), findsOneWidget);
  });

  testWidgets('cancel reaches pilot and restores installation controls', (
    tester,
  ) async {
    final pilot = _InteractivePilot();
    await open(tester, pilot);
    await tester.tap(find.text('Fetch catalogue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download and install'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(pilot.cancelCalls, 1);
    expect(find.textContaining('Pilot operation cancelled'), findsOneWidget);
    expect(installEnabled(tester), isTrue);
  });

  testWidgets(
    'removing delivery cache retains installation for offline verification',
    (tester) async {
      final pilot = _InteractivePilot()..installed = _installedTheme;
      await open(tester, pilot);
      await tester.ensureVisible(find.text('Remove Apple delivery copy'));
      await tester.tap(find.text('Remove Apple delivery copy'));
      await tester.pumpAndSettle();
      expect(pilot.removeDeliveryCalls, 1);
      expect(find.text('Marine Life — installed v2'), findsOneWidget);
      await tester.tap(find.text('Verify offline'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Offline verification passed'),
        findsOneWidget,
      );
      expect(pilot.installCalls, 0);

      await tester.tap(find.text('Remove installed pilot'));
      await tester.pumpAndSettle();
      expect(pilot.installed, isNull);
      expect(find.text('Marine Life — installed v2'), findsNothing);
      await tester.tap(find.text('Verify offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('No Marine Life installation was found.'),
        findsOneWidget,
      );
    },
  );

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

// UI state tests use a controlled pilot; archive integrity is exercised by
// marine_theme_pack_pilot_test.dart with the real installer and filesystem.
const _installedTheme = ThemeDefinition(
  id: 'marine',
  displayName: 'Marine Life',
  version: 2,
  tiles: [],
  audio: null,
  colours: ThemeColours(),
  typography: null,
);

class _InteractivePilot extends MarineThemePackPilot {
  _InteractivePilot()
    : super(
        delivery: _SupportedDelivery(),
        storagePaths: ThemeStoragePaths(Directory('/unused-test-path')),
        appBuild: 400,
      );

  Completer<ThemeDefinition> pending = Completer<ThemeDefinition>();
  ThemeDefinition? installed;
  int installCalls = 0;
  int cancelCalls = 0;
  int removeDeliveryCalls = 0;

  @override
  Future<MarinePilotDescriptor?> cachedCatalogue() async => null;
  @override
  Future<ThemeDefinition?> loadInstalled() async => installed;
  @override
  Future<MarinePilotDescriptor> fetchCatalogue() async =>
      MarinePilotDescriptor.fromCatalogue(
        jsonEncode({
          'catalogue_version': 1,
          'minimum_supported_app_build': 359,
          'themes': [
            {
              'id': 'marine',
              'version': 2,
              'minimum_app_build': 359,
              'file_size_bytes': 100,
              'sha256': 'a' * 64,
              'archive_path': 'ThemePacks/marine_v2.zip',
              'active': true,
              'is_free': true,
              'apple_asset_pack_id': 'marine',
            },
          ],
        }),
        appBuild,
      );
  @override
  Future<ThemeDefinition> downloadAndInstall(
    MarinePilotDescriptor descriptor, {
    void Function(String)? onStage,
  }) async {
    installCalls++;
    onStage?.call('Downloading Marine Life…');
    return installed = await pending.future;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    pending.completeError(const MarinePilotCancelledException());
  }

  @override
  Future<void> removeDeliveryCopy() async {
    removeDeliveryCalls++;
  }

  @override
  Future<void> removeInstallation() async {
    installed = null;
  }
}

class _SupportedDelivery extends AppleThemePackDelivery {
  @override
  Stream<AppleThemePackProgress> get progress => const Stream.empty();
  @override
  Future<AppleThemePackConfiguration> getConfiguration() async =>
      const AppleThemePackConfiguration(supported: true, configured: true);
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
