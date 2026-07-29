import 'dart:io';

import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/local_theme_pack_installer.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';

class LocalThemePackDeveloperInstaller {
  static const bool enabled = bool.fromEnvironment(
    'ENABLE_LOCAL_THEME_PACK_INSTALLER',
  );
  static const String zipPath = String.fromEnvironment('LOCAL_THEME_PACK_ZIP');

  const LocalThemePackDeveloperInstaller._();

  static Future<void> maybeInstall() async {
    if (!enabled || zipPath.trim().isEmpty) {
      return;
    }
    final storagePaths = await ThemeStoragePaths.applicationSupport();
    final installer = LocalThemePackInstaller(
      storagePaths: storagePaths,
      installedThemeStore: InstalledThemeStore(storagePaths: storagePaths),
    );
    try {
      final installedTheme = await installer.installFromZip(File(zipPath));
      AppDebug.log(
        'Installed local theme pack ${installedTheme.id} '
        'v${installedTheme.version}.',
      );
    } catch (error) {
      AppDebug.log('Local theme pack installation failed: $error');
      rethrow;
    }
  }
}
