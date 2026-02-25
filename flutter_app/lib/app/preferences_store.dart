import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStore {
  static const keyAnimalStyle = 'animal_style';
  static const keyContentMode = 'content_mode';
  static const keyStyleName = 'style_name';
  static const keyDifficulty = 'difficulty';
  static const keyPuzzleMode = 'puzzle_mode';

  Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(
      animalStyle: prefs.getString(keyAnimalStyle),
      contentMode: prefs.getString(keyContentMode),
      styleName: prefs.getString(keyStyleName),
      difficulty: prefs.getString(keyDifficulty),
      puzzleMode: prefs.getString(keyPuzzleMode),
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

  Future<void> savePuzzleMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPuzzleMode, value);
  }
}

class AppPreferences {
  final String? animalStyle;
  final String? contentMode;
  final String? styleName;
  final String? difficulty;
  final String? puzzleMode;

  const AppPreferences({
    required this.animalStyle,
    required this.contentMode,
    required this.styleName,
    required this.difficulty,
    required this.puzzleMode,
  });
}
