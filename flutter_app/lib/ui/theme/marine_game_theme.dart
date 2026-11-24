import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_loader.dart';
import 'package:flutter_app/ui/theme/theme_pack_validator.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';

/// Reads the installed free pilot without contacting Apple delivery.
class MarineGameTheme {
  static ThemeDefinition? definition;

  static Future<ThemeDefinition?> load() async {
    final store = InstalledThemeStore(
      storagePaths: await ThemeStoragePaths.applicationSupport(),
    );
    final installed = await store.readInstalledTheme('marine');
    if (installed == null || !installed.validated) return null;
    final validated = await const ThemePackValidator().validate(
      Directory(installed.rootPath),
    );
    if (validated.manifest.themeId != 'marine' ||
        validated.manifest.themeVersion != installed.version) {
      throw const FormatException('Marine Life metadata is inconsistent.');
    }
    return RepositoryThemeLoader(installedThemeStore: store)
        .loadInstalledTheme('marine');
  }

  static Future<Map<int, ui.Image>> decode(ThemeDefinition theme) async {
    final images = <int, ui.Image>{};
    try {
      for (var digit = 1; digit <= 9; digit++) {
        final bytes = await File(theme.tileForDigit(digit)!.imagePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          images[digit] = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
      }
      return images;
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
  }
}
