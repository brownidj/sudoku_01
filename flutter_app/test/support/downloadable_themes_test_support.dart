import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/downloadable_theme_catalog.dart';
import 'package:flutter_app/ui/theme/downloadable_themes_controller.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_purchase_gateway.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';

class TestThemePurchases extends ThemePurchaseGateway {
  final owned = <String>{};
  final bought = <String>[];
  final events = StreamController<void>.broadcast(sync: true);
  bool storeAvailable = true;
  String outcome = 'purchased';
  int restores = 0;
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<List<ThemeStoreProduct>> products(Set<String> ids) async =>
      storeAvailable
      ? [for (final id in ids) ThemeStoreProduct(id, r'$3.99')]
      : [];
  @override
  Future<bool> owns(String productId) async => owned.contains(productId);
  @override
  Future<String> purchase(String productId) async {
    bought.add(productId);
    if (outcome == 'purchased') owned.add(productId);
    return outcome;
  }

  @override
  Future<void> restore() async {
    restores++;
  }
}

class TestThemeDelivery extends AppleThemePackDelivery {
  bool supported = true;
  bool configured = true;
  @override
  Stream<AppleThemePackProgress> get progress => const Stream.empty();
  @override
  Future<AppleThemePackConfiguration> getConfiguration() async =>
      AppleThemePackConfiguration(supported: supported, configured: configured);
  @override
  Future<String> ensureAvailable({
    required String assetPackId,
    required String relativePath,
  }) async => throw StateError('No preview in this fixture.');
}

class TestThemePilot extends MarineThemePackPilot {
  TestThemePilot(String id, TestThemeDelivery native)
    : super(
        delivery: native,
        storagePaths: ThemeStoragePaths(Directory('/unused-test-path')),
        appBuild: 400,
        themeId: id,
      );
  bool published = true;
  bool failDownload = false;
  bool damaged = false;
  bool developerPack = false;
  int downloads = 0;
  int cancels = 0;
  ThemeDefinition? installed;
  Completer<ThemeDefinition>? pending;
  @override
  Future<MarinePilotDescriptor> fetchCatalogue() async {
    if (!published) throw const MarinePilotException('Not published');
    return MarinePilotDescriptor.fromCatalogue(
      jsonEncode({
        'catalogue_version': 1,
        'minimum_supported_app_build': 400,
        'themes': [
          {
            'id': themeId,
            'version': 2,
            'minimum_app_build': 400,
            'file_size_bytes': 1024,
            'sha256': 'a' * 64,
            'archive_path': 'ThemePacks/${themeId}_v2.zip',
            'is_free': false,
            'product_id': DownloadableTheme.byId(themeId).productId,
            'active': true,
            'apple_asset_pack_id': themeId,
          },
        ],
      }),
      400,
      themeId: themeId,
      expectedProductId: DownloadableTheme.byId(themeId).productId,
    );
  }

  @override
  Future<ThemeDefinition?> loadInstalled() async {
    if (damaged) throw const FormatException('Corrupt installation');
    return installed;
  }

  ThemeDefinition get definition => ThemeDefinition(
    id: themeId,
    productId: developerPack ? null : DownloadableTheme.byId(themeId).productId,
    displayName: DownloadableTheme.byId(themeId).name,
    version: 2,
    tiles: const [],
    audio: null,
    colours: const ThemeColours(),
    typography: null,
  );
  @override
  Future<ThemeDefinition> downloadAndInstall(
    MarinePilotDescriptor descriptor, {
    void Function(String)? onStage,
  }) async {
    downloads++;
    onStage?.call('Downloading Marine Life…');
    if (failDownload) throw const MarinePilotException('offline');
    final result = await (pending?.future ?? Future.value(definition));
    installed = result;
    return result;
  }

  @override
  Future<void> removeInstallation() async {
    installed = null;
    damaged = false;
  }

  @override
  Future<void> cancel() async {
    cancels++;
    pending?.completeError(const MarinePilotCancelledException());
  }
}

class ThemeStoreFixture {
  final purchases = TestThemePurchases();
  final native = TestThemeDelivery();
  late final pilots = {
    for (final theme in DownloadableTheme.all)
      theme.id: TestThemePilot(theme.id, native),
  };
  late final controller = DownloadableThemesController(
    purchases: purchases,
    delivery: pilots,
  );
  Future<void> dispose() async {
    controller.dispose();
    await purchases.events.close();
  }
}
