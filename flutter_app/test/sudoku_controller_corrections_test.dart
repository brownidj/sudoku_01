import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/application/solver.dart';
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
    'prompt appears when selecting dead tile and clears incorrect tiles only',
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

      final solvedGrid = solveGrid(
        List<List<int?>>.generate(9, (r) {
          return List<int?>.generate(
            9,
            (c) => controller.state.board.cells[r][c].given
                ? controller.state.board.cells[r][c].value
                : null,
            growable: false,
          );
        }, growable: false),
      );
      expect(solvedGrid, isNotNull);

      Coord? extraWrongCoord;
      int? extraWrongDigit;
      for (var r = 0; r < 9; r += 1) {
        for (var c = 0; c < 9; c += 1) {
          if (controller.state.board.cells[r][c].given ||
              controller.state.board.cells[r][c].value != null ||
              const Coord(6, 8) == Coord(r, c)) {
            continue;
          }
          final solvedValue = solvedGrid![r][c];
          if (solvedValue == null) {
            continue;
          }
          extraWrongCoord = Coord(r, c);
          extraWrongDigit = solvedValue == 1 ? 2 : 1;
          break;
        }
        if (extraWrongCoord != null) {
          break;
        }
      }
      expect(extraWrongCoord, isNotNull);
      expect(extraWrongDigit, isNotNull);

      controller.onCellTapped(extraWrongCoord!);
      controller.onDigitPressed(extraWrongDigit!);
      expect(
        controller
            .state
            .board
            .cells[extraWrongCoord.row][extraWrongCoord.col]
            .value,
        extraWrongDigit,
      );

      controller.onCellTapped(const Coord(6, 8));
      expect(controller.state.correctionPromptCoord, const Coord(6, 8));

      controller.onConfirmCorrection();

      expect(controller.state.board.cells[0][8].value, isNull);
      expect(controller.state.board.cells[0][8].reverted, isTrue);
      expect(
        controller
            .state
            .board
            .cells[extraWrongCoord.row][extraWrongCoord.col]
            .value,
        isNull,
      );
      expect(
        controller
            .state
            .board
            .cells[extraWrongCoord.row][extraWrongCoord.col]
            .reverted,
        isTrue,
      );
      expect(controller.state.board.cells[4][4].value, 5);
      expect(controller.state.correctionPromptCoord, isNull);
      expect(controller.state.correctionsLeft, 2);
      expect(controller.state.correctionNoticeMessage, '2 tile(s) corrected.');
      expect(controller.state.correctionNoticeSerial, 1);
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
