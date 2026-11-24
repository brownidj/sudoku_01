import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late ThemeStoragePaths paths;
  late _Delivery delivery;
  late MarineThemePackPilot pilot;
  late Map<String, Object?> catalogue;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('marine_pilot_test_');
    paths = ThemeStoragePaths(Directory('${root.path}/themes'));
    final zip = await _pack(root);
    catalogue = _catalogue(zip);
    final catalogueFile = File('${root.path}/catalogue.json');
    await catalogueFile.writeAsString(jsonEncode(catalogue));
    delivery = _Delivery(catalogueFile, zip);
    pilot = MarineThemePackPilot(
      delivery: delivery,
      storagePaths: paths,
      appBuild: 359,
    );
  });

  tearDown(() => root.delete(recursive: true));

  test('downloads, verifies and installs through the shared loader', () async {
    final descriptor = await pilot.fetchCatalogue();
    final theme = await pilot.downloadAndInstall(descriptor);
    expect(theme.id, 'marine');
    expect(theme.version, 1);
    expect(theme.tiles, hasLength(9));
    expect(
      theme.tiles.first.imagePath,
      startsWith(paths.installedDirectory.path),
    );
    expect(delivery.requests, ['theme_catalogue', 'marine']);
    expect(await paths.currentFile('marine').exists(), isTrue);
    expect(await paths.tempDirectory.list().toList(), isEmpty);
    expect(
      await delivery.zip.exists(),
      isTrue,
      reason: 'Apple delivery copy is retained.',
    );
  });

  test(
    'offline verification reads installed assets without native calls',
    () async {
      await pilot.downloadAndInstall(await pilot.fetchCatalogue());
      delivery.requests.clear();
      delivery.offline = true;
      final reopened = MarineThemePackPilot(
        delivery: delivery,
        storagePaths: paths,
        appBuild: 359,
      );
      expect((await reopened.loadInstalled())?.tiles, hasLength(9));
      expect(await reopened.cachedCatalogue(), isNotNull);
      expect(delivery.requests, isEmpty);
    },
  );

  test('failed refresh uses the previous valid catalogue', () async {
    await pilot.fetchCatalogue();
    await delivery.catalogue.writeAsString('{broken');
    expect((await pilot.fetchCatalogue()).version, 1);
    expect(pilot.usedCachedCatalogue, isTrue);
    expect(pilot.catalogueWarning, isNotNull);
    expect((await pilot.cachedCatalogue())?.version, 1);
  });

  test(
    'rejects a corrupt checksum before installing and cleans temporary files',
    () async {
      final entry =
          (catalogue['themes'] as List).single as Map<String, Object?>;
      entry['sha256'] = '0' * 64;
      final descriptor = MarinePilotDescriptor.fromCatalogue(
        jsonEncode(catalogue),
        359,
      );
      await expectLater(
        pilot.downloadAndInstall(descriptor),
        throwsA(isA<MarinePilotException>()),
      );
      expect(await paths.currentFile('marine').exists(), isFalse);
      expect(await paths.tempDirectory.list().toList(), isEmpty);
    },
  );

  test('rejects an incorrect archive size before extracting', () async {
    final entry = (catalogue['themes'] as List).single as Map<String, Object?>;
    entry['file_size_bytes'] = delivery.zip.lengthSync() + 1;
    final descriptor = MarinePilotDescriptor.fromCatalogue(
      jsonEncode(catalogue),
      359,
    );
    await expectLater(
      pilot.downloadAndInstall(descriptor),
      throwsA(isA<MarinePilotException>()),
    );
    expect(await paths.currentFile('marine').exists(), isFalse);
  });

  for (final scenario in ['identity', 'version', 'compatibility']) {
    test('rejects manifest $scenario mismatch before activation', () async {
      await _pack(
        root,
        themeId: scenario == 'identity' ? 'wrong_theme' : 'marine',
        version: scenario == 'version' ? 2 : 1,
        minimumBuild: scenario == 'compatibility' ? 999 : 359,
      );
      final descriptor = MarinePilotDescriptor.fromCatalogue(
        jsonEncode(_catalogue(delivery.zip)),
        359,
      );
      await expectLater(
        pilot.downloadAndInstall(descriptor),
        throwsA(isA<InvalidThemeManifestException>()),
      );
      expect(await paths.currentFile('marine').exists(), isFalse);
      expect(await paths.currentFile('wrong_theme').exists(), isFalse);
      expect(await paths.tempDirectory.list().toList(), isEmpty);
    });
  }

  test(
    'cancellation aborts native delivery without activating anything',
    () async {
      final descriptor = await pilot.fetchCatalogue();
      delivery.waitForMarine = true;
      final pending = pilot.downloadAndInstall(descriptor);
      final assertion = expectLater(
        pending,
        throwsA(isA<MarinePilotCancelledException>()),
      );
      await delivery.started.future;
      await pilot.cancel();
      await assertion;
      expect(delivery.cancelled, ['marine']);
      expect(await paths.currentFile('marine').exists(), isFalse);
    },
  );

  test(
    'cancellation before activation removes extracted and copied files',
    () async {
      final descriptor = await pilot.fetchCatalogue();
      await expectLater(
        pilot.downloadAndInstall(
          descriptor,
          onStage: (stage) {
            if (stage.startsWith('Validating')) unawaited(pilot.cancel());
          },
        ),
        throwsA(isA<MarinePilotCancelledException>()),
      );
      expect(await paths.currentFile('marine').exists(), isFalse);
      expect(await paths.tempDirectory.list().toList(), isEmpty);
    },
  );

  test(
    'different incoming version preserves the working installation',
    () async {
      await pilot.downloadAndInstall(await pilot.fetchCatalogue());
      final before = await paths.currentFile('marine').readAsString();
      final entry =
          (catalogue['themes'] as List).single as Map<String, Object?>;
      entry['version'] = 2;
      entry['archive_path'] = 'ThemePacks/marine_v2.zip';
      final descriptor = MarinePilotDescriptor.fromCatalogue(
        jsonEncode(catalogue),
        359,
      );
      await expectLater(
        pilot.downloadAndInstall(descriptor),
        throwsA(isA<MarinePilotException>()),
      );
      expect(await paths.currentFile('marine').readAsString(), before);
      expect((await pilot.loadInstalled())?.version, 1);
    },
  );

  test('damaged installed asset fails offline verification', () async {
    final theme = await pilot.downloadAndInstall(await pilot.fetchCatalogue());
    await File(theme.tiles.first.imagePath).writeAsBytes([1, 2, 3]);
    await expectLater(
      pilot.loadInstalled(),
      throwsA(isA<ThemeChecksumMismatchException>()),
    );
  });

  test('delivery removal retains a verified private installation', () async {
    await pilot.downloadAndInstall(await pilot.fetchCatalogue());
    await pilot.removeDeliveryCopy();
    expect(delivery.removed, ['marine']);
    expect((await pilot.loadInstalled())?.tiles, hasLength(9));
    await pilot.removeInstallation();
    expect(await pilot.loadInstalled(), isNull);
    expect(await pilot.cachedCatalogue(), isNotNull);
  });

  test('paid, incompatible and duplicate catalogue entries are rejected', () {
    for (final alteration in ['paid', 'build', 'duplicate', 'path']) {
      final json = _catalogue(delivery.zip);
      final themes = json['themes'] as List;
      final entry = themes.single as Map<String, Object?>;
      if (alteration == 'paid') entry['is_free'] = false;
      if (alteration == 'build') entry['minimum_app_build'] = 999;
      if (alteration == 'duplicate') themes.add(Map.of(entry));
      if (alteration == 'path') entry['archive_path'] = '../marine.zip';
      expect(
        () => MarinePilotDescriptor.fromCatalogue(jsonEncode(json), 359),
        throwsA(isA<MarinePilotException>()),
      );
    }
  });
}

Map<String, Object?> _catalogue(File zip) => {
  'catalogue_version': 1,
  'minimum_supported_app_build': 359,
  'themes': <Object?>[
    <String, Object?>{
      'id': 'marine',
      'version': 1,
      'minimum_app_build': 359,
      'apple_asset_pack_id': 'marine',
      'archive_path': 'ThemePacks/marine_v1.zip',
      'file_size_bytes': zip.lengthSync(),
      'sha256': sha256.convert(zip.readAsBytesSync()).toString(),
      'active': true,
      'is_free': true,
    },
  ],
};

Future<File> _pack(
  Directory root, {
  String themeId = 'marine',
  int version = 1,
  int minimumBuild = 359,
}) async {
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a0BsAAAAASUVORK5CYII=',
  );
  final files = <String, List<int>>{
    'preview.png': png,
    for (var i = 1; i <= 9; i++) 'tiles/tile_$i.png': png,
  };
  final manifest = {
    'schema_version': 1,
    'theme_id': themeId,
    'theme_version': version,
    'display_name': 'Marine Life',
    'tile_count': 9,
    'preview_path': 'preview.png',
    'minimum_app_build': minimumBuild,
    'tiles': [
      for (var i = 1; i <= 9; i++)
        {
          'id': 'tile_$i',
          'path': 'tiles/tile_$i.png',
          'accessibility_label': 'Creature $i',
        },
    ],
    'checksums': {
      for (final entry in files.entries)
        entry.key: sha256.convert(entry.value).toString(),
    },
  };
  final archive = Archive();
  for (final entry in <String, List<int>>{
    'manifest.json': utf8.encode(jsonEncode(manifest)),
    ...files,
  }.entries) {
    archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
  }
  return File(
    '${root.path}/native_marine.zip',
  ).writeAsBytes(ZipEncoder().encode(archive));
}

class _Delivery extends AppleThemePackDelivery {
  final File catalogue;
  final File zip;
  final requests = <String>[];
  final cancelled = <String>[];
  final removed = <String>[];
  final started = Completer<void>();
  final pending = Completer<String>();
  bool offline = false;
  bool waitForMarine = false;

  _Delivery(this.catalogue, this.zip);

  @override
  Stream<AppleThemePackProgress> get progress => const Stream.empty();

  @override
  Future<String> ensureAvailable({
    required String assetPackId,
    required String relativePath,
  }) async {
    requests.add(assetPackId);
    if (offline) throw PlatformException(code: 'offline');
    if (assetPackId == 'marine' && waitForMarine) {
      started.complete();
      return pending.future;
    }
    return assetPackId == 'theme_catalogue' ? catalogue.path : zip.path;
  }

  @override
  Future<void> cancelDownload(String assetPackId) async {
    cancelled.add(assetPackId);
    if (!pending.isCompleted) {
      pending.completeError(PlatformException(code: 'cancelled'));
    }
  }

  @override
  Future<void> removeAssetPack(String assetPackId) async {
    removed.add(assetPackId);
  }
}
