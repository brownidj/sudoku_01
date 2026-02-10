import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStore {
  static const keyAnimalStyle = 'animal_style';
  static const keyContentMode = 'content_mode';
  static const keyStyleName = 'style_name';
  static const keyDifficulty = 'difficulty';

  Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(
      animalStyle: prefs.getString(keyAnimalStyle),
      contentMode: prefs.getString(keyContentMode),
      styleName: prefs.getString(keyStyleName),
      difficulty: prefs.getString(keyDifficulty),
    );
  }

  Future<void> saveAnimalStyle(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAnimalStyle, value);
  }

  Future<void> saveContentMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyContentMode, value);
  }

  Future<void> saveStyleName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyStyleName, value);
  }

  Future<void> saveDifficulty(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDifficulty, value);
  }
}

class AppPreferences {
  final String? animalStyle;
  final String? contentMode;
  final String? styleName;
  final String? difficulty;

  const AppPreferences({
    required this.animalStyle,
    required this.contentMode,
    required this.styleName,
    required this.difficulty,
  });
}
