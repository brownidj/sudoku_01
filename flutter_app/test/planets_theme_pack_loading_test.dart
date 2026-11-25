import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_manifest.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloadable_themes_test_support.dart';

const planets = [
  'mars',
  'venus',
  'earth',
  'mercury',
  'jupiter',
  'saturn',
  'uranus',
  'neptune',
  'pluto',
];
const takeCounts = [3, 3, 3, 4, 2, 2, 2, 2, 3];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late Directory version;
  late ThemeStoragePaths paths;
  late TestThemePurchases purchases;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('planets_installed_');
    paths = ThemeStoragePaths(root);
    version = paths.versionDirectory('planets', 1);
    final checksums = <String, String>{};
    Future<String> copy(String source, String relative) async {
      final target = File('${version.path}/$relative');
      await target.parent.create(recursive: true);
      await File(source).copy(target.path);
      checksums[relative] = (await sha256.bind(target.openRead()).first)
          .toString();
      return relative;
    }

    final tiles = <Map<String, Object?>>[];
    final audio = <Map<String, Object?>>[];
    final music = <String>[];
    for (var digit = 1; digit <= 9; digit++) {
      final name = planets[digit - 1];
      final image = '${digit}_${name}_01.png';
      final path = await copy('assets/images/planets/$image', 'tiles/$image');
      tiles.add({
        'id': name,
        'path': path,
        'accessibility_label': '${name[0].toUpperCase()}${name.substring(1)}',
      });
      final tunes = <String>[];
      for (var take = 1; take <= takeCounts[digit - 1]; take++) {
        final filename = '${digit}_${name}_$take.mp3';
        tunes.add(
          await copy('assets/audio/planets/$filename', 'audio/$filename'),
        );
      }
      audio.add({
        'digit': digit,
        'long_press': tunes.first,
        'long_press_variants': tunes,
      });
      music.addAll(tunes);
    }
    final manifest = {
      'schema_version': 1,
      'theme_id': 'planets',
      'theme_version': 1,
      'display_name': 'Planets',
      'product_id': 'theme_planets',
      'tile_count': 9,
      'tiles': tiles,
      'preview_path': tiles.first['path'],
      'audio': {'tiles': audio, 'music': music},
      'checksums': checksums,
    };
    await File(
      '${version.path}/manifest.json',
    ).writeAsString(jsonEncode(manifest));
    await InstalledThemeStore(storagePaths: paths).writeCurrent(
      manifest: ThemeManifest.fromJson(manifest),
      installedAt: DateTime.now(),
    );
  });
  setUp(() => purchases = TestThemePurchases());
  tearDown(() async {
    MarineGameTheme.definitions.remove('planets');
    await purchases.events.close();
  });
  tearDownAll(() async {
    await root.delete(recursive: true);
  });

  test(
    'owned Planets loads all real images, correct names, own random tunes and 24 background tracks offline',
    () async {
      purchases.owned.add('theme_planets');
      final theme = (await MarineGameTheme.load(
        themeId: 'planets',
        storagePaths: paths,
        purchases: purchases,
      ))!;
      expect(theme.productId, 'theme_planets');
      final decoded = await MarineGameTheme.decode(theme);
      expect(decoded, hasLength(9));
      for (final image in decoded.values) {
        expect(image.width, greaterThan(0));
        image.dispose();
      }
      MarineGameTheme.definitions['planets'] = theme;
      final random = Random(42);
      for (var digit = 1; digit <= 9; digit++) {
        final name = planets[digit - 1];
        expect(
          theme.tileForDigit(digit)!.displayName,
          '${name[0].toUpperCase()}${name.substring(1)}',
        );
        final variants = theme.audio!.tilePreviewVariants[digit]!;
        expect(variants, hasLength(takeCounts[digit - 1]));
        expect(variants.map((path) => File(path).uri.pathSegments.last), [
          for (var take = 1; take <= takeCounts[digit - 1]; take++)
            '${digit}_${name}_$take.mp3',
        ]);
        final choices = {
          for (var attempt = 0; attempt < 100; attempt++)
            theme.audio!.tilePreviewAssetForDigit(digit, random: random),
        };
        expect(choices, variants.toSet());
        expect(
          SudokuTilePreviewAudioService.audioAssetForTile(
            contentMode: 'planets',
            digit: digit,
          ),
          isIn(variants),
        );
        expect(
          backgroundTracksForContentMode('planets'),
          containsAll(variants),
        );
      }
      expect(backgroundTracksForContentMode('planets'), hasLength(24));
      for (final installed in backgroundTracksForContentMode('planets')) {
        final filename = File(installed).uri.pathSegments.last;
        expect(
          (await sha256.bind(File(installed).openRead()).first).toString(),
          (await sha256
                  .bind(File('assets/audio/planets/$filename').openRead())
                  .first)
              .toString(),
        );
      }
    },
  );

  test(
    'local Planets developer copy is loaded only in the explicitly opted-in build',
    () async {
      final file = File('${version.path}/manifest.json');
      final original = await file.readAsString();
      try {
        final manifest = jsonDecode(original) as Map<String, dynamic>;
        manifest['product_id'] = null;
        await file.writeAsString(jsonEncode(manifest));
        final theme = await MarineGameTheme.load(
          themeId: 'planets',
          storagePaths: paths,
          purchases: purchases,
        );
        expect(
          theme != null,
          const bool.fromEnvironment('PLANETS_DEVELOPER_PACK'),
        );
        if (theme != null) {
          expect(theme.productId, isNull);
          expect(theme.audio!.backgroundMusicAssets, hasLength(24));
        }
        expect(purchases.owned, isEmpty);
      } finally {
        await file.writeAsString(original);
      }
    },
  );

  test(
    'Planets requires its own current entitlement; Marine Life and Full Version do not unlock it',
    () async {
      purchases.owned.addAll(['theme_marine', 'premium_unlock']);
      expect(
        await MarineGameTheme.load(
          themeId: 'planets',
          storagePaths: paths,
          purchases: purchases,
        ),
        isNull,
      );
      purchases.owned.add('theme_planets');
      expect(
        await MarineGameTheme.load(
          themeId: 'planets',
          storagePaths: paths,
          purchases: purchases,
        ),
        isNotNull,
      );
      purchases.owned.remove('theme_planets');
      expect(
        await MarineGameTheme.load(
          themeId: 'planets',
          storagePaths: paths,
          purchases: purchases,
        ),
        isNull,
      );
    },
  );

  test(
    'a corrupt alternative tune is rejected even when the first tune is intact',
    () async {
      purchases.owned.add('theme_planets');
      final target = File('${version.path}/audio/4_mercury_4.mp3');
      try {
        await target.writeAsString('corrupt alternative');
        await expectLater(
          MarineGameTheme.load(
            themeId: 'planets',
            storagePaths: paths,
            purchases: purchases,
          ),
          throwsA(isA<ThemeChecksumMismatchException>()),
        );
      } finally {
        await File('assets/audio/planets/4_mercury_4.mp3').copy(target.path);
      }
    },
  );
}
