import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/domain/types.dart';

class PreferencesStore {
  static const keyAnimalStyle = 'animal_style';
  static const keyContentMode = 'content_mode';
  static const keyStyleName = 'style_name';
  static const keyDifficulty = 'difficulty';
  static const keyPuzzleMode = 'puzzle_mode';
  static const keyGameSession = 'game_session';
  static const keyCompletedPuzzles = 'completed_puzzles';
  static const keyEntitlement = 'entitlement';

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

  Future<String?> loadGameSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyGameSession);
  }

  Future<void> saveGameSession(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyGameSession, value);
  }

  Future<void> clearGameSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyGameSession);
  }

  Future<int> loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCompletedPuzzles) ?? 0;
  }

  Future<void> saveCompletedPuzzles(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCompletedPuzzles, value);
  }

  Future<Entitlement> loadEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(keyEntitlement);
    return _parseEntitlement(rawValue);
  }

  Future<void> saveEntitlement(Entitlement value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyEntitlement, value.name);
  }

  Entitlement _parseEntitlement(String? rawValue) {
    if (rawValue == null) {
      return Entitlement.free;
    }
    for (final entitlement in Entitlement.values) {
      if (entitlement.name == rawValue) {
        return entitlement;
      }
    }
    return Entitlement.free;
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
