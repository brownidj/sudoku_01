import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_app/ui/theme/composite_theme_repository.dart';
import 'package:flutter_app/ui/theme/installed_theme_repository.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/local_theme_pack_installer.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_loader.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalThemePackInstaller', () {
    late Directory tempDirectory;
    late ThemeStoragePaths storagePaths;
    late LocalThemePackInstaller installer;
    late InstalledThemeStore store;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'local_theme_pack_test_',
      );
      storagePaths = ThemeStoragePaths(
        Directory('${tempDirectory.path}/themes'),
      );
      store = InstalledThemeStore(storagePaths: storagePaths);
      installer = LocalThemePackInstaller(
        storagePaths: storagePaths,
        installedThemeStore: store,
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('installs a valid local pack atomically', () async {
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: _validFiles(),
      );

      final installedTheme = await installer.installFromZip(zipFile);

      expect(installedTheme.id, 'garden');
      expect(installedTheme.version, 2);
      expect(
        await File(
          '${storagePaths.versionDirectory('garden', 2).path}/manifest.json',
        ).exists(),
        isTrue,
      );
      expect(
        await storagePaths.installingDirectory('garden', 2).exists(),
        isFalse,
      );
      expect(await _recursiveEntryCount(storagePaths.tempDirectory), 0);
    });

    test('rejects an invalid ZIP archive', () async {
      final zipFile = File('${tempDirectory.path}/invalid.zip');
      await zipFile.writeAsString('not a zip');

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<InvalidThemeZipException>()),
      );
    });

    test('rejects a ZIP file that is not found', () async {
      expect(
        () =>
            installer.installFromZip(File('${tempDirectory.path}/missing.zip')),
        throwsA(isA<ThemeZipNotFoundException>()),
      );
    });

    test('rejects a pack without manifest.json', () async {
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: null,
        files: {
          'tiles/tile_01.webp': [1, 2, 3],
        },
      );

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<MissingThemeManifestException>()),
      );
    });

    test('rejects a malformed manifest', () async {
      final zipFile = await _writeRawZip(tempDirectory, {
        'manifest.json': utf8.encode('{not-json'),
      });

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<InvalidThemeManifestException>()),
      );
    });

    test('rejects a missing asset', () async {
      final manifest = _validManifest();
      final files = _validFiles()..remove('tiles/tile_09.webp');
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: manifest,
        files: files,
      );

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<MissingThemeAssetException>()),
      );
    });

    test('rejects a checksum mismatch', () async {
      final manifest = _validManifest(
        checksums: {'tiles/tile_01.webp': List.filled(64, '0').join()},
      );
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: manifest,
        files: _validFiles(),
      );

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<ThemeChecksumMismatchException>()),
      );
    });

    test('rejects an already installed duplicate pack', () async {
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: _validFiles(),
        name: 'garden_v2.zip',
      );
      await installer.installFromZip(zipFile);
      final duplicateZip = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: _validFiles(),
        name: 'garden_v2_duplicate.zip',
      );

      expect(
        () => installer.installFromZip(duplicateZip),
        throwsA(
          isA<DuplicateThemePackException>().having(
            (error) => error.comparison,
            'comparison',
            ThemePackDuplicateComparison.identical,
          ),
        ),
      );
    });

    test('rejects a path traversal attempt', () async {
      final outsideFile = File('${tempDirectory.path}/outside.txt');
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: {
          ..._validFiles(),
          '../outside.txt': [1, 2, 3],
        },
      );

      expect(
        () => installer.installFromZip(zipFile),
        throwsA(isA<UnsafeThemeArchivePathException>()),
      );
      expect(await outsideFile.exists(), isFalse);
    });

    test('cleans up staging files after failed installation', () async {
      final files = _validFiles()..remove('preview.webp');
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: files,
      );

      await expectLater(
        installer.installFromZip(zipFile),
        throwsA(isA<MissingThemeAssetException>()),
      );

      expect(await storagePaths.themeDirectory('garden').exists(), isFalse);
      expect(await _recursiveEntryCount(storagePaths.tempDirectory), 0);
    });

    test('installed theme is discoverable through ThemeLoader', () async {
      final zipFile = await _writeZip(
        tempDirectory,
        manifest: _validManifest(),
        files: _validFiles(),
      );
      await installer.installFromZip(zipFile);
      final loader = RepositoryThemeLoader(installedThemeStore: store);
      final installedRepository = InstalledThemeRepository(
        installedThemeStore: store,
        themeLoader: loader,
      );
      final repository = CompositeThemeRepository(
        installedRepository: installedRepository,
      );

      final definition = await loader.loadInstalledTheme('garden');
      final themes = await repository.getAvailableThemes();
      final loadedFromRepository = await repository.loadTheme('garden');

      expect(definition.id, 'garden');
      expect(definition.tiles, hasLength(9));
      expect(definition.tiles.first.imagePath, contains('/tiles/tile_01.webp'));
      expect(themes.any((theme) => theme.id == 'garden'), isTrue);
      expect(loadedFromRepository, isA<ThemeDefinition>());
      expect(loadedFromRepository.id, 'garden');
    });
  });
}

Map<String, Object?> _validManifest({Map<String, String>? checksums}) {
  final files = _validFiles();
  final computedChecksums = <String, String>{
    for (final entry in files.entries)
      entry.key: sha256.convert(entry.value).toString(),
  };
  return {
    'schema_version': 1,
    'theme_id': 'garden',
    'theme_version': 2,
    'display_name': 'Garden',
    'tile_count': 9,
    'tiles': [
      for (var digit = 1; digit <= 9; digit += 1)
        {
          'id': 'tile_$digit',
          'path': 'tiles/tile_0$digit.webp',
          'accessibility_label': 'Tile $digit',
        },
    ],
    'preview_path': 'preview.webp',
    'audio': {
      'tiles': [
        {'digit': 1, 'long_press': 'audio/tile_01.m4a'},
      ],
      'music': ['audio/music.m4a'],
    },
    'colours': {
      'background': '#FFFFFF',
      'grid': '#000000',
      'highlight': '#D6ECFF',
    },
    'checksums': checksums ?? computedChecksums,
  };
}

Map<String, List<int>> _validFiles() {
  return {
    'preview.webp': [10, 11, 12],
    for (var digit = 1; digit <= 9; digit += 1)
      'tiles/tile_0$digit.webp': [digit, digit + 1, digit + 2],
    'audio/tile_01.m4a': [21, 22, 23],
    'audio/music.m4a': [31, 32, 33],
  };
}

Future<File> _writeZip(
  Directory directory, {
  required Map<String, Object?>? manifest,
  required Map<String, List<int>> files,
  String name = 'theme.zip',
}) {
  final zipFiles = <String, List<int>>{
    if (manifest != null) 'manifest.json': utf8.encode(jsonEncode(manifest)),
    ...files,
  };
  return _writeRawZip(directory, zipFiles, name: name);
}

Future<File> _writeRawZip(
  Directory directory,
  Map<String, List<int>> files, {
  String name = 'theme.zip',
}) async {
  final archive = Archive();
  for (final entry in files.entries) {
    archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
  }
  final zipFile = File('${directory.path}/$name');
  await zipFile.writeAsBytes(ZipEncoder().encode(archive));
  return zipFile;
}

Future<int> _recursiveEntryCount(Directory directory) async {
  if (!await directory.exists()) {
    return 0;
  }
  var count = 0;
  await for (final entity in directory.list(
    recursive: true,
    followLinks: false,
  )) {
    entity.path;
    count += 1;
  }
  return count;
}
