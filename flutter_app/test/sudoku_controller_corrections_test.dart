import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  SettingsState settingsFor(String difficulty) {
    return SettingsState(
      notesMode: false,
      difficulty: difficulty,
      canChangeDifficulty: true,
      canChangePuzzleMode: true,
      styleName: 'Modern',
      contentMode: 'numbers',
      animalStyle: 'simple',
      puzzleMode: difficulty == 'easy' ? 'multi' : 'unique',
    );
  }

  test(
    'prompt appears when selecting dead tile and clears targeted tiles',
    () async {
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: FakeGameService(),
        settingsController: FakeSettingsController(settingsFor('medium')),
      );
      await controller.ready;

      controller.onLoadCorrectionScenario();
      expect(controller.state.correctionPromptCoord, const Coord(6, 8));
      controller.onDismissCorrectionPrompt();
      expect(controller.state.correctionPromptCoord, isNull);
      expect(controller.state.board.cells[0][8].value, 4);

      controller.onCellTapped(const Coord(0, 2));
      expect(controller.state.correctionPromptCoord, isNull);

      controller.onCellTapped(const Coord(6, 8));
      expect(controller.state.correctionPromptCoord, const Coord(6, 8));
      expect(controller.state.correctionsLeft, 3);

      controller.onConfirmCorrection();

      final corrected = controller.state.board.cells[0][8];
      expect(corrected.value, isNull);
      expect(corrected.reverted, isTrue);
      expect(controller.state.correctionPromptCoord, isNull);
      expect(controller.state.correctionsLeft, 2);
      expect(controller.state.canUndo, isTrue);
    },
  );

  test('exhausted corrections use undo-only path', () async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('hard')),
    );
    await controller.ready;

    controller.onLoadExhaustedCorrectionScenario();
    expect(controller.state.correctionsLeft, 0);

    controller.onCellTapped(const Coord(6, 8));

    expect(controller.state.correctionPromptCoord, isNull);
    expect(controller.state.canUndo, isTrue);
    expect(controller.state.board.cells[0][8].value, 4);

    controller.onUndo();

    expect(controller.state.board.cells[0][8].value, isNull);
  });

  test('correction state persists in saved session', () async {
    final prefs = FakePreferencesStore();
    final controller = SudokuController(
      preferencesStore: prefs,
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('medium')),
    );
    await controller.ready;

    controller.onLoadCorrectionScenario();
    controller.onDismissCorrectionPrompt();
    controller.onCellTapped(const Coord(6, 8));
    controller.onConfirmCorrection();

    final restored = SudokuController(
      preferencesStore: prefs,
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('medium')),
    );
    await restored.ready;

    expect(restored.state.correctionsLeft, 2);
    expect(restored.state.board.cells[0][8].reverted, isTrue);
  });
}
