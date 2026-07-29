import 'dart:io';

import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_manifest.dart';
import 'package:path/path.dart' as p;

abstract class ThemeLoader {
  Future<ThemeDefinition> loadBundledTheme(String themeId);

  Future<ThemeDefinition> loadInstalledTheme(String themeId);
}

class RepositoryThemeLoader implements ThemeLoader {
  final BundledThemeRepository bundledRepository;
  final InstalledThemeStore installedThemeStore;

  const RepositoryThemeLoader({
    this.bundledRepository = const BundledThemeRepository(),
    required this.installedThemeStore,
  });

  @override
  Future<ThemeDefinition> loadBundledTheme(String themeId) {
    return bundledRepository.loadTheme(themeId);
  }

  @override
  Future<ThemeDefinition> loadInstalledTheme(String themeId) async {
    final installedTheme = await installedThemeStore.readInstalledTheme(
      themeId,
    );
    if (installedTheme == null || !installedTheme.validated) {
      throw UnknownThemeException(themeId);
    }
    final manifest = await installedThemeStore.readManifest(installedTheme);
    return _definitionFromManifest(
      manifest,
      rootDirectory: Directory(installedTheme.rootPath),
    );
  }

  ThemeDefinition _definitionFromManifest(
    ThemeManifest manifest, {
    required Directory rootDirectory,
  }) {
    return ThemeDefinition(
      id: manifest.themeId,
      displayName: manifest.displayName,
      version: manifest.themeVersion,
      tiles: [
        for (var index = 0; index < manifest.tiles.length; index += 1)
          _tileFromManifest(
            manifest.tiles[index],
            digit: index + 1,
            rootDirectory: rootDirectory,
          ),
      ],
      audio: _audioFromManifest(manifest.audio, rootDirectory),
      colours: ThemeColours(
        background: manifest.colours.background,
        grid: manifest.colours.grid,
        highlight: manifest.colours.highlight,
      ),
      typography: null,
    );
  }

  ThemeTile _tileFromManifest(
    ThemeManifestTile tile, {
    required int digit,
    required Directory rootDirectory,
  }) {
    final label = tile.accessibilityLabel ?? tile.id;
    return ThemeTile(
      id: tile.id,
      imagePath: _absoluteAssetPath(rootDirectory, tile.path),
      accessibilityLabel: tile.accessibilityLabel,
      displayName: label,
      label: digit.toString(),
    );
  }

  ThemeAudio _audioFromManifest(
    ThemeManifestAudio audio,
    Directory rootDirectory,
  ) {
    final previewAssets = <int, String>{};
    final celebrationAssets = <int, String>{};
    for (final tileAudio in audio.tiles) {
      final longPress = tileAudio.longPress;
      final celebration = tileAudio.celebration;
      if (longPress != null) {
        previewAssets[tileAudio.digit] = _absoluteAssetPath(
          rootDirectory,
          longPress,
        );
      }
      if (celebration != null) {
        celebrationAssets[tileAudio.digit] = _absoluteAssetPath(
          rootDirectory,
          celebration,
        );
      }
    }
    return ThemeAudio(
      tilePreviewAssets: Map.unmodifiable(previewAssets),
      tileCelebrationAssets: Map.unmodifiable(celebrationAssets),
      backgroundMusicAssets: [
        for (final musicPath in audio.music)
          _absoluteAssetPath(rootDirectory, musicPath),
      ],
    );
  }

  String _absoluteAssetPath(Directory rootDirectory, String relativePath) {
    return p.normalize(p.join(rootDirectory.path, relativePath));
  }
}
