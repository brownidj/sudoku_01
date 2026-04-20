import 'dart:convert';

import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('selection changes are persisted into saved session settings', () async {
    final fakePrefs = FakePreferencesStore();
    final controller = SudokuController(
      preferencesStore: fakePrefs,
      settingsController: FakeSettingsController(
        const SettingsState(
          notesMode: false,
          difficulty: 'easy',
          canChangeDifficulty: true,
          canChangePuzzleMode: true,
          styleName: 'Modern',
          contentMode: 'animals',
          animalStyle: 'cute',
          puzzleMode: 'unique',
        ),
      ),
      gameService: FakeGameService(),
    );
    await controller.ready;

    controller.onStyleChanged('Classic');
    controller.onContentModeChanged('instruments');
    controller.onAnimalStyleChanged('simple');
    controller.setNotesMode(true);
    await controller.flushGameSession();

    final payload = jsonDecode(fakePrefs.savedSession!) as Map<String, dynamic>;
    final settings = payload['settings'] as Map<String, dynamic>;
    expect(settings['styleName'], 'Classic');
    expect(settings['contentMode'], 'instruments');
    expect(settings['animalStyle'], 'simple');
    expect(settings['notesMode'], isTrue);
  });
}
