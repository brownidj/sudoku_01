import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';

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
    expect(fakeSettings.state.canChangeDifficulty, false);
    expect(fakeSettings.state.canChangePuzzleMode, false);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    controller.onCheckSolution();
    expect(fakeSettings.state.canChangeDifficulty, true);
    expect(fakeSettings.state.canChangePuzzleMode, true);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 4);

    controller.onSetDifficulty('hard');
    expect(fakeSettings.state.puzzleMode, 'unique');

    controller.onContentModeChanged('numbers');
    expect(fakeSettings.state.contentMode, 'numbers');
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

  test('difficulty gating uses policy in controller path', () async {
    final freeController = SudokuController(
      preferencesStore: FakePreferencesStore(entitlement: Entitlement.free),
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
    await freeController.ready;
    freeController.onSetDifficulty('hard');
    expect(freeController.state.difficulty, 'easy');

    final premiumController = SudokuController(
      preferencesStore: FakePreferencesStore(entitlement: Entitlement.premium),
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
    await premiumController.ready;
    premiumController.onSetDifficulty('hard');
    expect(premiumController.state.difficulty, 'hard');
  });

  test('controller queries policy service for difficulty checks', () async {
    final policySpy = SpyPremiumPolicyService(
      byDifficulty: {'hard': false},
      defaultDifficultyResult: true,
    );
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(entitlement: Entitlement.premium),
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
      premiumPolicyService: policySpy,
    );
    await controller.ready;

    final allowedEasy = controller.isDifficultyUnlocked('easy');
    controller.onSetDifficulty('hard');

    expect(allowedEasy, isTrue);
    expect(controller.state.difficulty, 'easy');
    expect(
      policySpy.difficultyChecks,
      containsAll(['easy:premium', 'hard:premium']),
    );
  });
}
