import 'package:flutter_app/app/preferences_store.dart';

class ProgressMetricsService {
  final PreferencesStore _preferencesStore;

  const ProgressMetricsService(this._preferencesStore);

  Future<int> loadCompletedPuzzles() {
    return _preferencesStore.loadCompletedPuzzles();
  }

  Future<void> saveCompletedPuzzles(int value) {
    return _preferencesStore.saveCompletedPuzzles(value);
  }
}
