import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';

class SettingsController {
  final PreferencesStore _prefs;
  final void Function() _onChange;

  SettingsState _state = const SettingsState(
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    styleName: 'Modern',
    contentMode: 'animals',
    animalStyle: 'cute',
  );

  SettingsController(this._prefs, this._onChange);

  SettingsState get state => _state;

  Future<void> load() async {
    final prefs = await _prefs.load();
    var next = _state;
    if (prefs.animalStyle == 'cute' || prefs.animalStyle == 'simple') {
      next = next.copyWith(animalStyle: prefs.animalStyle);
    }
    if (prefs.contentMode == 'animals' || prefs.contentMode == 'numbers') {
      next = next.copyWith(contentMode: prefs.contentMode);
    }
    if (prefs.styleName != null && prefs.styleName!.isNotEmpty) {
      next = next.copyWith(styleName: prefs.styleName);
    }
    if (prefs.difficulty != null && ['easy', 'medium', 'hard'].contains(prefs.difficulty)) {
      next = next.copyWith(difficulty: prefs.difficulty);
    }
    _setState(next);
  }

  void toggleNotesMode() {
    _setState(_state.copyWith(notesMode: !_state.notesMode));
  }

  bool setDifficulty(String difficulty) {
    if (!_state.canChangeDifficulty) {
      return false;
    }
    _setState(_state.copyWith(difficulty: difficulty));
    _prefs.saveDifficulty(difficulty);
    return true;
  }

  void setDifficultyLocked(bool locked) {
    _setState(_state.copyWith(canChangeDifficulty: !locked));
  }

  void setStyleName(String styleName) {
    _setState(_state.copyWith(styleName: styleName));
    _prefs.saveStyleName(styleName);
  }

  void setContentMode(String mode) {
    _setState(_state.copyWith(contentMode: mode));
    _prefs.saveContentMode(mode);
  }

  void setAnimalStyle(String style) {
    _setState(_state.copyWith(animalStyle: style));
    _prefs.saveAnimalStyle(style);
  }

  void _setState(SettingsState next) {
    _state = next;
    _onChange();
  }
}
