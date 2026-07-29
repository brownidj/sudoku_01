import 'dart:async';

import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_loader.dart';
import 'package:flutter_app/ui/theme/theme_repository.dart';

class InstalledThemeRepository implements ThemeRepository {
  final InstalledThemeStore installedThemeStore;
  final ThemeLoader themeLoader;

  const InstalledThemeRepository({
    required this.installedThemeStore,
    required this.themeLoader,
  });

  @override
  Future<List<ThemeSummary>> getAvailableThemes() async {
    final themes = <ThemeSummary>[];
    for (final installedTheme
        in await installedThemeStore.listInstalledThemes()) {
      final manifest = await installedThemeStore.readManifest(installedTheme);
      themes.add(
        ThemeSummary(
          id: manifest.themeId,
          displayName: manifest.displayName,
          description: 'Installed local theme pack.',
          previewImage: '${installedTheme.rootPath}/${manifest.previewPath}',
          source: ThemeSource.downloaded,
          isInstalled: true,
          isOwned: true,
          hasUpdate: false,
          version: manifest.themeVersion,
        ),
      );
    }
    return themes;
  }

  @override
  Future<bool> isInstalled(String themeId) async {
    return installedThemeStore
        .readInstalledTheme(themeId)
        .then((theme) => theme != null);
  }

  @override
  Future<void> installTheme(String themeId) async {
    if (!await isInstalled(themeId)) {
      throw UnknownThemeException(themeId);
    }
  }

  @override
  Future<ThemeDefinition> loadTheme(String themeId) {
    return themeLoader.loadInstalledTheme(themeId);
  }

  @override
  Future<void> removeTheme(String themeId) async {
    if (!await isInstalled(themeId)) {
      throw UnknownThemeException(themeId);
    }
    await installedThemeStore.removeTheme(themeId);
  }

  @override
  Stream<List<ThemeSummary>> watchThemes() async* {
    yield await getAvailableThemes();
  }
}
