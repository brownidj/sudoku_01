import 'package:flutter_app/ui/services/app_version_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef StartInstructionVersionKeyLoader = Future<String> Function();
typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

class StartInstructionTooltipService {
  static const String _keyLastSeenVersion = 'start_instruction_last_version';
  static const String _keyShownCount = 'start_instruction_shown_count';
  static const int _maxShowsPerVersion = 2;

  final StartInstructionVersionKeyLoader _versionKeyLoader;
  final SharedPreferencesLoader _sharedPreferencesLoader;

  String? _cachedVersionKey;

  StartInstructionTooltipService({
    StartInstructionVersionKeyLoader? versionKeyLoader,
    SharedPreferencesLoader? sharedPreferencesLoader,
    AppVersionService appVersionService = const AppVersionService(),
  }) : _versionKeyLoader =
           versionKeyLoader ?? (() => appVersionService.loadDisplayVersion()),
       _sharedPreferencesLoader =
           sharedPreferencesLoader ?? SharedPreferences.getInstance;

  Future<bool> consumeDisplayOpportunity() async {
    final prefs = await _sharedPreferencesLoader();
    final versionKey = await _resolvedVersionKey();
    final storedVersion = prefs.getString(_keyLastSeenVersion);
    final shownCount = prefs.getInt(_keyShownCount) ?? 0;

    if (storedVersion != versionKey) {
      await prefs.setString(_keyLastSeenVersion, versionKey);
      await prefs.setInt(_keyShownCount, 1);
      return true;
    }

    if (shownCount >= _maxShowsPerVersion) {
      return false;
    }

    await prefs.setInt(_keyShownCount, shownCount + 1);
    return true;
  }

  Future<String> _resolvedVersionKey() async {
    final cached = _cachedVersionKey;
    if (cached != null) {
      return cached;
    }
    final loaded = await _versionKeyLoader();
    _cachedVersionKey = loaded.trim().isEmpty
        ? 'unknown-version'
        : loaded.trim();
    return _cachedVersionKey!;
  }
}
