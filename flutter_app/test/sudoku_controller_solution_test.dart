import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test(
    'Show solution from active game reveals unsolved tiles immediately',
    () async {
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
            puzzleMode: 'multi',
          ),
        ),
      );
      await controller.ready;

      controller.onShowSolution();
      final state = controller.state;

      expect(state.gameOver, isTrue);
      final hasSolutionAdded = state.board.cells
          .expand((row) => row)
          .any((cell) => cell.solutionAdded);
      expect(hasSolutionAdded, isTrue);
    },
  );

  test(
    'Show solution replaces incorrect tile and marks it as solution-added',
    () async {
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
            puzzleMode: 'multi',
          ),
        ),
      );
      await controller.ready;

      final editable = firstEditableCoord(controller.state);
      expect(editable, isNotNull);
      final badDigit = conflictingPeerDigit(controller.state, editable!);
      expect(badDigit, isNotNull);

      controller.onCellTapped(editable);
      controller.onDigitPressed(badDigit!);
      controller.onShowSolution();

      final cell = controller.state.board.cells[editable.row][editable.col];
      expect(cell.solutionAdded, isTrue);
      expect(cell.incorrect, isFalse);
      expect(cell.value, isNot(badDigit));
    },
  );

  test('Duplicate placement is highlighted and can be cleared', () async {
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
          puzzleMode: 'multi',
        ),
      ),
    );
    await controller.ready;

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    final badDigit = conflictingPeerDigit(controller.state, editable!);
    expect(badDigit, isNotNull);

    controller.onCellTapped(editable);
    controller.onDigitPressed(badDigit!);

    final conflicted = controller.state.board.cells[editable.row][editable.col];
    expect(conflicted.value, badDigit);
    expect(conflicted.conflicted, isTrue);

    controller.onClearPressed();
    final cleared = controller.state.board.cells[editable.row][editable.col];
    expect(cleared.value, isNull);
    expect(cleared.conflicted, isFalse);
  });
}
