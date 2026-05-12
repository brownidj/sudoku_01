import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/domain/types.dart';

class PreferencesStore {
  static const _disableBackgroundMusicForTests = bool.fromEnvironment(
    'DISABLE_BACKGROUND_MUSIC_FOR_TESTS',
    defaultValue: false,
  );
  static const keyAnimalStyle = 'animal_style';
  static const keyContentMode = 'content_mode';
  static const keyStyleName = 'style_name';
  static const keyDifficulty = 'difficulty';
  static const keyPuzzleMode = 'puzzle_mode';
  static const keyGameSession = 'game_session';
  static const keyCompletedPuzzles = 'completed_puzzles';
  static const keyDaysPlayed = 'days_played';
  static const keyCurrentStreak = 'current_streak';
  static const keyLastPlayedDate = 'last_played_date';
  static const keyPlayedDates = 'played_dates';
  static const keyBestSolveTimeEasySeconds = 'best_solve_time_easy_seconds';
  static const keyBestSolveTimeMediumSeconds =
      'best_solve_time_medium_seconds';
  static const keyBestSolveTimeHardSeconds = 'best_solve_time_hard_seconds';
  static const keyBestSolveTimeVeryHardSeconds =
      'best_solve_time_very_hard_seconds';
  static const keyEntitlement = 'entitlement';
  static const keyAudioEnabled = 'audio_enabled';
  static const keyBackgroundMusicEnabled = 'background_music_enabled';
  static const keyAudioVolume = 'audio_volume';
  static const keyPreferredLanguageCode = 'preferred_language_code';

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

  Future<void> clearProgressMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCompletedPuzzles);
    await prefs.remove(keyDaysPlayed);
    await prefs.remove(keyCurrentStreak);
    await prefs.remove(keyLastPlayedDate);
    await prefs.remove(keyPlayedDates);
    await prefs.remove(keyBestSolveTimeEasySeconds);
    await prefs.remove(keyBestSolveTimeMediumSeconds);
    await prefs.remove(keyBestSolveTimeHardSeconds);
    await prefs.remove(keyBestSolveTimeVeryHardSeconds);
  }

  Future<int> loadDaysPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyDaysPlayed) ?? 0;
  }

  Future<void> saveDaysPlayed(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyDaysPlayed, value);
  }

  Future<int> loadCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCurrentStreak) ?? 0;
  }

  Future<void> saveCurrentStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCurrentStreak, value);
  }

  Future<String?> loadLastPlayedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastPlayedDate);
  }

  Future<void> saveLastPlayedDate(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastPlayedDate, value);
  }

  Future<List<String>> loadPlayedDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyPlayedDates) ?? const <String>[];
  }

  Future<void> savePlayedDates(List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyPlayedDates, value);
  }

  Future<int?> loadBestSolveTimeSeconds(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _bestSolveTimeKeyForDifficulty(difficulty);
    return key == null ? null : prefs.getInt(key);
  }

  Future<void> saveBestSolveTimeSeconds(String difficulty, int value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _bestSolveTimeKeyForDifficulty(difficulty);
    if (key == null) {
      return;
    }
    await prefs.setInt(key, value);
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

  Future<bool> loadAudioEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyAudioEnabled) ?? true;
  }

  Future<void> saveAudioEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAudioEnabled, value);
  }

  Future<bool> loadBackgroundMusicEnabled() async {
    if (_disableBackgroundMusicForTests) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyBackgroundMusicEnabled) ?? true;
  }

  Future<void> saveBackgroundMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyBackgroundMusicEnabled, value);
  }

  Future<double> loadAudioVolume() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(keyAudioVolume);
    if (stored == null) {
      return 0.4;
    }
    return stored.clamp(0.0, 1.0);
  }

  Future<void> saveAudioVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyAudioVolume, value.clamp(0.0, 1.0));
  }

  Future<String?> loadPreferredLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPreferredLanguageCode);
  }

  Future<void> savePreferredLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPreferredLanguageCode, languageCode);
  }

  Future<void> clearPreferredLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyPreferredLanguageCode);
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

  String? _bestSolveTimeKeyForDifficulty(String difficulty) {
    switch (difficulty.trim().toLowerCase()) {
      case 'easy':
        return keyBestSolveTimeEasySeconds;
      case 'medium':
        return keyBestSolveTimeMediumSeconds;
      case 'hard':
        return keyBestSolveTimeHardSeconds;
      case 'very_hard':
        return keyBestSolveTimeVeryHardSeconds;
      default:
        return null;
    }
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
