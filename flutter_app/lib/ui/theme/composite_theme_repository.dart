import 'dart:async';

import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_repository.dart';

class CompositeThemeRepository implements ThemeRepository {
  final ThemeRepository bundledRepository;
  final ThemeRepository installedRepository;

  const CompositeThemeRepository({
    this.bundledRepository = const BundledThemeRepository(),
    required this.installedRepository,
  });

  @override
  Future<List<ThemeSummary>> getAvailableThemes() async {
    return <ThemeSummary>[
      ...await bundledRepository.getAvailableThemes(),
      ...await installedRepository.getAvailableThemes(),
    ];
  }

  @override
  Future<bool> isInstalled(String themeId) async {
    return await bundledRepository.isInstalled(themeId) ||
        await installedRepository.isInstalled(themeId);
  }

  @override
  Future<void> installTheme(String themeId) async {
    if (await bundledRepository.isInstalled(themeId)) {
      await bundledRepository.installTheme(themeId);
      return;
    }
    await installedRepository.installTheme(themeId);
  }

  @override
  Future<ThemeDefinition> loadTheme(String themeId) async {
    if (await bundledRepository.isInstalled(themeId)) {
      return bundledRepository.loadTheme(themeId);
    }
    return installedRepository.loadTheme(themeId);
  }

  @override
  Future<void> removeTheme(String themeId) async {
    if (await bundledRepository.isInstalled(themeId)) {
      await bundledRepository.removeTheme(themeId);
      return;
    }
    await installedRepository.removeTheme(themeId);
  }

  @override
  Stream<List<ThemeSummary>> watchThemes() async* {
    yield await getAvailableThemes();
  }
}
