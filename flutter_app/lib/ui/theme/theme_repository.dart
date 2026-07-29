import 'package:flutter_app/ui/theme/theme_definition.dart';

abstract class ThemeRepository {
  Future<List<ThemeSummary>> getAvailableThemes();

  Future<ThemeDefinition> loadTheme(String themeId);

  Future<bool> isInstalled(String themeId);

  Future<void> installTheme(String themeId);

  Future<void> removeTheme(String themeId);

  Stream<List<ThemeSummary>> watchThemes();
}
