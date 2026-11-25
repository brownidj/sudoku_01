import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_loader.dart';
import 'package:flutter_app/ui/theme/theme_pack_validator.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:flutter_app/ui/theme/downloadable_theme_catalog.dart';
import 'package:flutter_app/ui/theme/theme_purchase_gateway.dart';

/// Reads validated installed themes without contacting Apple delivery.
/// The Marine Life getter is retained for compatibility with the debug pilot.
class MarineGameTheme {
  static final definitions = <String, ThemeDefinition>{};
  static ThemeDefinition? get definition => definitions['marine'];
  static set definition(ThemeDefinition? value) {
    if (value == null) {
      definitions.remove('marine');
    } else {
      definitions['marine'] = value;
    }
  }

  static bool isDownloaded(String id) =>
      const ['marine', 'planets', 'buttons'].contains(id);

  static Future<ThemeDefinition?> load({
    String themeId = 'marine',
    ThemeStoragePaths? storagePaths,
    ThemePurchaseGateway purchases = const ThemePurchaseGateway(),
  }) async {
    final store = InstalledThemeStore(
      storagePaths:
          storagePaths ?? await ThemeStoragePaths.applicationSupport(),
    );
    final installed = await store.readInstalledTheme(themeId);
    if (installed == null || !installed.validated) return null;
    final validated = await const ThemePackValidator().validate(
      Directory(installed.rootPath),
    );
    if (validated.manifest.themeId != themeId ||
        validated.manifest.themeVersion != installed.version) {
      throw const FormatException('Installed theme metadata is inconsistent.');
    }
    final productId = validated.manifest.productId;
    if (productId == null && !DownloadableTheme.permitsDeveloperPack(themeId)) {
      return null;
    }
    if (productId != null &&
        (productId != DownloadableTheme.byId(themeId).productId ||
            !await purchases.owns(productId))) {
      return null;
    }
    return RepositoryThemeLoader(
      installedThemeStore: store,
    ).loadInstalledTheme(themeId);
  }

  static Future<Map<int, ui.Image>> decode(ThemeDefinition theme) async {
    final images = <int, ui.Image>{};
    try {
      for (var digit = 1; digit <= 9; digit++) {
        final bytes = await File(
          theme.tileForDigit(digit)!.imagePath,
        ).readAsBytes();
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
