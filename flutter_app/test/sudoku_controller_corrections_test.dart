import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

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

  test('contradiction prompts for correction and reverts on confirm', () async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('medium')),
    );
    await controller.ready;

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    final badDigit = conflictingPeerDigit(controller.state, editable!);
    expect(badDigit, isNotNull);

    controller.onCellTapped(editable);
    controller.onDigitPressed(badDigit!);

    expect(controller.state.correctionPromptMoveId, isNotNull);
    expect(controller.state.correctionsLeft, 3);
    expect(
      controller.state.board.cells[editable.row][editable.col].value,
      badDigit,
    );

    controller.onConfirmCorrection();

    final cell = controller.state.board.cells[editable.row][editable.col];
    expect(controller.state.correctionsLeft, 2);
    expect(controller.state.correctionPromptMoveId, isNull);
    expect(controller.state.canUndo, isFalse);
    expect(cell.value, isNull);
    expect(cell.reverted, isTrue);
  });

  test(
    'exhausted corrections leave contradiction in place and allow undo',
    () async {
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: FakeGameService(),
        settingsController: FakeSettingsController(settingsFor('hard')),
      );
      await controller.ready;

      final editable = firstEditableCoord(controller.state);
      expect(editable, isNotNull);

      controller.onCellTapped(editable!);
      controller.onDigitPressed(
        conflictingPeerDigit(controller.state, editable)!,
      );
      controller.onConfirmCorrection();

      expect(controller.state.correctionsLeft, 0);

      controller.onCellTapped(editable);
      controller.onDigitPressed(
        conflictingPeerDigit(controller.state, editable)!,
      );

      expect(controller.state.correctionPromptMoveId, isNull);
      expect(controller.state.canUndo, isTrue);
      expect(
        controller.state.board.cells[editable.row][editable.col].conflicted,
        isTrue,
      );

      controller.onUndo();

      expect(
        controller.state.board.cells[editable.row][editable.col].value,
        isNull,
      );
      expect(controller.state.canUndo, isFalse);
    },
  );

  test('correction state persists in saved session', () async {
    final prefs = FakePreferencesStore();
    final controller = SudokuController(
      preferencesStore: prefs,
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('medium')),
    );
    await controller.ready;

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(
      conflictingPeerDigit(controller.state, editable)!,
    );
    controller.onConfirmCorrection();

    final restored = SudokuController(
      preferencesStore: prefs,
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(settingsFor('medium')),
    );
    await restored.ready;

    expect(restored.state.correctionsLeft, 2);
    expect(
      restored.state.board.cells[editable.row][editable.col].reverted,
      isTrue,
    );
  });
}
