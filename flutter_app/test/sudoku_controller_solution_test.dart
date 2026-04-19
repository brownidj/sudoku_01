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
            canChangeDifficulty: false,
            canChangePuzzleMode: false,
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
      expect(state.canChangeDifficulty, isTrue);
      expect(state.canChangePuzzleMode, isTrue);
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

  test('completed puzzle metric increments once per solved puzzle', () async {
    final prefs = FakePreferencesStore(completedPuzzles: 2);
    final controller = SudokuController(
      preferencesStore: prefs,
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
    expect(controller.completedPuzzles, 2);

    controller.onCompletePuzzleWithSolution();
    await Future<void>.delayed(Duration.zero);
    expect(controller.completedPuzzles, 3);
    expect(prefs.completedPuzzles, 3);

    controller.onCompletePuzzleWithSolution();
    await Future<void>.delayed(Duration.zero);
    expect(controller.completedPuzzles, 3);
    expect(prefs.completedPuzzles, 3);
  });

  test('abandoning an in-progress game does not increment completed puzzles', () async {
    final prefs = FakePreferencesStore(completedPuzzles: 5);
    final controller = SudokuController(
      preferencesStore: prefs,
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
    expect(controller.completedPuzzles, 5);

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);
    controller.onNewGame();
    await Future<void>.delayed(Duration.zero);

    expect(controller.completedPuzzles, 5);
    expect(prefs.completedPuzzles, 5);
  });

  test('show solution give-up path does not increment completed puzzles', () async {
    final prefs = FakePreferencesStore(completedPuzzles: 6);
    final controller = SudokuController(
      preferencesStore: prefs,
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
    expect(controller.completedPuzzles, 6);

    controller.onShowSolution();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.gameOver, isTrue);
    expect(controller.state.puzzleSolved, isFalse);
    expect(controller.completedPuzzles, 6);
    expect(prefs.completedPuzzles, 6);
  });
}
