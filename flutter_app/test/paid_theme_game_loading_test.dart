import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_manifest.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloadable_themes_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late ThemeStoragePaths paths;
  late TestThemePurchases purchases;
  late Map<String, Object?> manifest;
  late List<File> fishImages;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('paid_theme_game_');
    paths = ThemeStoragePaths(root);
    purchases = TestThemePurchases();
    final version = paths.versionDirectory('marine', 4);
    await version.create(recursive: true);
    fishImages =
        Directory('assets/images/marine')
            .listSync()
            .whereType<File>()
            .where(
              (file) => RegExp(
                r'^[1-9]_.+_butterflyfish\.png$',
              ).hasMatch(file.uri.pathSegments.last),
            )
            .toList()
          ..sort(
            (a, b) =>
                a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last),
          );
    expect(fishImages, hasLength(9));
    final tiles = <Map<String, Object?>>[];
    final files = <String, List<int>>{};
    for (final image in fishImages) {
      final filename = image.uri.pathSegments.last;
      final name = filename.substring(
        2,
        filename.length - '_butterflyfish.png'.length,
      );
      final label =
          '${name.split('_').map((part) => '${part[0].toUpperCase()}${part.substring(1)}').join(' ')} Butterfly Fish';
      final path = 'tiles/$filename';
      files[path] = await image.readAsBytes();
      tiles.add({
        'id': filename.substring(2, filename.length - 4),
        'path': path,
        'accessibility_label': label,
      });
    }
    for (final name in [
      '1_threadfin_1.mp3',
      '1_threadfin_2.mp3',
      '2_copperband_1.wav',
      '2_copperband_2.wav',
      '3_raccoon_1.wav',
      '3_raccoon_2.wav',
      '8_redtail_1.wav',
      '8_redtail_2.wav',
    ]) {
      files['audio/$name'] = await File(
        'assets/audio/marine/$name',
      ).readAsBytes();
    }
    for (final entry in files.entries) {
      final target = File('${version.path}/${entry.key}');
      await target.parent.create(recursive: true);
      await target.writeAsBytes(entry.value);
    }
    manifest = {
      'schema_version': 1,
      'theme_id': 'marine',
      'theme_version': 4,
      'product_id': 'theme_marine',
      'display_name': 'Marine Life',
      'tile_count': 9,
      'preview_path': tiles.first['path'],
      'tiles': tiles,
      'audio': {
        'tiles': [
          {
            'digit': 1,
            'long_press': 'audio/1_threadfin_1.mp3',
            'long_press_variants': [
              'audio/1_threadfin_1.mp3',
              'audio/1_threadfin_2.mp3',
            ],
          },
          {
            'digit': 3,
            'long_press': 'audio/3_raccoon_1.wav',
            'long_press_variants': [
              'audio/3_raccoon_1.wav',
              'audio/3_raccoon_2.wav',
            ],
          },
          {
            'digit': 2,
            'long_press': 'audio/2_copperband_1.wav',
            'long_press_variants': [
              'audio/2_copperband_1.wav',
              'audio/2_copperband_2.wav',
            ],
          },
          {
            'digit': 8,
            'long_press': 'audio/8_redtail_1.wav',
            'long_press_variants': [
              'audio/8_redtail_1.wav',
              'audio/8_redtail_2.wav',
            ],
          },
        ],
        'music': [
          'audio/1_threadfin_1.mp3',
          'audio/1_threadfin_2.mp3',
          'audio/2_copperband_1.wav',
          'audio/2_copperband_2.wav',
          'audio/3_raccoon_1.wav',
          'audio/3_raccoon_2.wav',
          'audio/8_redtail_1.wav',
          'audio/8_redtail_2.wav',
        ],
      },
      'checksums': {
        for (final entry in files.entries)
          entry.key: sha256.convert(entry.value).toString(),
      },
    };
    await File(
      '${version.path}/manifest.json',
    ).writeAsString(jsonEncode(manifest));
    await InstalledThemeStore(storagePaths: paths).writeCurrent(
      manifest: ThemeManifest.fromJson(manifest),
      installedAt: DateTime.now(),
    );
  });
  tearDown(() async {
    await purchases.events.close();
    await root.delete(recursive: true);
  });

  test(
    'owned installed theme loads its nine decoded images, creature sounds and music offline',
    () async {
      purchases.owned.add('theme_marine');
      final theme = (await MarineGameTheme.load(
        storagePaths: paths,
        purchases: purchases,
      ))!;
      final images = await MarineGameTheme.decode(theme);
      expect(
        images.keys,
        orderedEquals(List.generate(9, (index) => index + 1)),
      );
      for (final image in images.values) {
        expect(image.width, greaterThan(0));
        image.dispose();
      }
      expect(theme.audio!.tilePreviewAssets, hasLength(4));
      expect(theme.tiles.first.displayName, 'Threadfin Butterfly Fish');
      expect(theme.tileForDigit(7)!.displayName, 'Blackback Butterfly Fish');
      expect(theme.tiles.last.displayName, 'Pyramid Butterfly Fish');
      expect(theme.audio!.tilePreviewAssetForDigit(7), isNull);
      expect(theme.audio!.tilePreviewVariants[1], hasLength(2));
      expect(theme.audio!.tilePreviewVariants[3], hasLength(2));
      final redtail = theme.audio!.tilePreviewVariants[8]!;
      expect(redtail, hasLength(2));
      expect(theme.audio!.tilePreviewVariants[2], hasLength(2));
      expect(
        theme.audio!.backgroundMusicAssets,
        containsAll(theme.audio!.tilePreviewVariants[2]!),
      );
      for (final installed in theme.audio!.backgroundMusicAssets) {
        final name = File(installed).uri.pathSegments.last;
        expect(
          sha256.convert(await File(installed).readAsBytes()).toString(),
          sha256
              .convert(await File('assets/audio/marine/$name').readAsBytes())
              .toString(),
        );
      }
      expect(theme.audio!.backgroundMusicAssets, hasLength(8));
      expect(theme.audio!.backgroundMusicAssets, containsAll(redtail));
    },
  );

  test(
    'missing or revoked purchase and Full Version ownership do not unlock a paid theme',
    () async {
      purchases.owned.add('premium_unlock');
      expect(
        await MarineGameTheme.load(storagePaths: paths, purchases: purchases),
        isNull,
      );
      purchases.owned.add('theme_marine');
      expect(
        await MarineGameTheme.load(storagePaths: paths, purchases: purchases),
        isNotNull,
      );
      purchases.owned.remove('theme_marine');
      expect(
        await MarineGameTheme.load(storagePaths: paths, purchases: purchases),
        isNull,
      );
    },
  );

  test(
    'corrupt installed assets cannot become selectable even with a purchase',
    () async {
      purchases.owned.add('theme_marine');
      await File(
        '${paths.versionDirectory('marine', 4).path}/${(manifest['tiles'] as List).first['path']}',
      ).writeAsString('corrupt');
      await expectLater(
        MarineGameTheme.load(storagePaths: paths, purchases: purchases),
        throwsException,
      );
    },
  );
}
