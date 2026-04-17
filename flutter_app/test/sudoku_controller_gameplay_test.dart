import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('Puzzle mode defaults, locking, and new game flow', () async {
    final fakeGameService = FakeGameService();
    final fakePrefs = FakePreferencesStore();
    final fakeSettings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'multi',
      ),
    );

    final controller = SudokuController(
      preferencesStore: fakePrefs,
      gameService: fakeGameService,
      settingsController: fakeSettings,
    );
    await controller.ready;

    expect(fakeGameService.newGameCalls, 1);
    expect(controller.hadSavedSessionAtLaunch, isFalse);

    controller.onSetDifficulty('medium');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 2);

    controller.onPuzzleModeChanged('multi');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);
    expect(fakeSettings.state.canChangePuzzleMode, false);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    controller.onCheckSolution();
    expect(fakeSettings.state.canChangePuzzleMode, true);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 4);

    controller.onSetDifficulty('hard');
    expect(fakeSettings.state.puzzleMode, 'unique');

    controller.onContentModeChanged('numbers');
    expect(fakeSettings.state.contentMode, 'numbers');
    controller.onContentModeChanged('instruments');
    expect(fakeSettings.state.contentMode, 'instruments');
  });

  test('conflict peer hints are limited per game by difficulty', () async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(
        const SettingsState(
          notesMode: false,
          difficulty: 'easy',
          canChangeDifficulty: true,
          canChangePuzzleMode: true,
          styleName: 'Modern',
          contentMode: 'numbers',
          animalStyle: 'simple',
          puzzleMode: 'unique',
        ),
      ),
    );
    await controller.ready;

    final target = firstEditableCoord(controller.state);
    expect(target, isNotNull);
    final conflictDigit = conflictingPeerDigit(controller.state, target!);
    expect(conflictDigit, isNotNull);

    int conflictedCount() {
      return controller.state.board.cells
          .expand((row) => row)
          .where((cell) => cell.conflicted)
          .length;
    }

    controller.onCellTapped(target);
    controller.onDigitPressed(conflictDigit!);
    expect(controller.state.conflictHintsLeft, 2);
    expect(conflictedCount(), greaterThan(1));

    controller.onClearPressed();
    controller.onDigitPressed(conflictDigit);
    expect(controller.state.conflictHintsLeft, 1);
    expect(conflictedCount(), greaterThan(1));

    controller.onClearPressed();
    controller.onDigitPressed(conflictDigit);
    expect(controller.state.conflictHintsLeft, 0);
    expect(conflictedCount(), greaterThan(1));

    controller.onClearPressed();
    controller.onDigitPressed(conflictDigit);
    expect(controller.state.conflictHintsLeft, 0);
    expect(conflictedCount(), 1);
  });
}
