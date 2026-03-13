import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('loads correction debug scenario with pending prompt', () async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(
        const SettingsState(
          notesMode: false,
          difficulty: 'hard',
          canChangeDifficulty: true,
          canChangePuzzleMode: true,
          styleName: 'Classic',
          contentMode: 'numbers',
          animalStyle: 'simple',
          puzzleMode: 'unique',
        ),
      ),
    );
    await controller.ready;

    controller.onLoadCorrectionScenario();

    final state = controller.state;
    expect(state.difficulty, 'easy');
    expect(state.puzzleMode, 'multi');
    expect(state.canChangeDifficulty, isFalse);
    expect(state.canChangePuzzleMode, isFalse);
    expect(state.correctionPromptCoord, const Coord(6, 8));
    expect(state.correctionsLeft, 3);
    expect(state.debugScenarioLabel, 'Debug scenario: correction available');
    expect(state.selected, const Coord(6, 8));
    expect(state.board.cells[0][8].value, 4);
    expect(state.board.cells[6][8].conflicted, isTrue);
  });

  test('loads exhausted correction scenario for undo-only recovery', () async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(
        const SettingsState(
          notesMode: false,
          difficulty: 'medium',
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

    controller.onLoadExhaustedCorrectionScenario();

    final state = controller.state;
    expect(state.difficulty, 'easy');
    expect(state.puzzleMode, 'multi');
    expect(state.correctionPromptCoord, isNull);
    expect(state.correctionsLeft, 0);
    expect(state.debugScenarioLabel, 'Debug scenario: corrections exhausted');
    expect(state.canUndo, isTrue);
    expect(state.selected, const Coord(0, 8));
    expect(state.board.cells[0][8].value, 4);
    expect(state.board.cells[6][8].conflicted, isTrue);
  });

  test(
    'reloading correction debug scenario preserves reduced corrections',
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

      controller.onLoadCorrectionScenario();
      controller.onConfirmCorrection();
      expect(controller.state.correctionsLeft, 2);

      controller.onLoadCorrectionScenario();
      expect(controller.state.correctionsLeft, 2);

      controller.onConfirmCorrection();
      expect(controller.state.correctionsLeft, 1);
    },
  );
}
