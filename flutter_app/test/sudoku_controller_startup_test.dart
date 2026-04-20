import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('SudokuController uses injected services', () async {
    final fakeGameService = FakeGameService();
    final fakePrefs = FakePreferencesStore();
    final fakeSettings = FakeSettingsController(
      const SettingsState(
        notesMode: true,
        difficulty: 'hard',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Classic',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'unique',
      ),
    );

    final controller = SudokuController(
      preferencesStore: fakePrefs,
      gameService: fakeGameService,
      settingsController: fakeSettings,
    );
    await controller.ready;

    expect(fakeGameService.initialHistoryCalls, 1);
    expect(fakeGameService.newGameCalls, 1);
    expect(fakeSettings.loadCalls, 1);
    expect(controller.hadSavedSessionAtLaunch, isFalse);

    final state = controller.state;
    expect(state.difficulty, 'hard');
    expect(state.styleName, 'Classic');
    expect(state.contentMode, 'numbers');
    expect(state.animalStyle, 'simple');
  });

  test('Loads saved game session instead of starting a new game', () async {
    final fakePrefs = FakePreferencesStore();
    final seedSettings = FakeSettingsController(
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
    final seedController = SudokuController(
      preferencesStore: fakePrefs,
      settingsController: seedSettings,
      gameService: FakeGameService(),
    );
    await seedController.ready;
    final editable = firstEditableCoord(seedController.state);
    expect(editable, isNotNull);
    seedController.onCellTapped(editable!);
    seedController.onDigitPressed(1);
    expect(fakePrefs.savedSession, isNotNull);

    final restoreGameService = FakeGameService();
    final restoreSettings = FakeSettingsController(
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
    final restoreController = SudokuController(
      preferencesStore: fakePrefs,
      gameService: restoreGameService,
      settingsController: restoreSettings,
    );
    await restoreController.ready;

    expect(restoreGameService.newGameCalls, 0);
    expect(restoreController.hadSavedSessionAtLaunch, isTrue);
    final restoredCell =
        restoreController.state.board.cells[editable.row][editable.col];
    expect(restoredCell.value, 1);

    final sessionJson = jsonDecode(fakePrefs.savedSession!);
    expect(sessionJson['version'], 2);
  });

  test(
    'Restored easy session clamps legacy correction count to new max',
    () async {
      final fakePrefs = FakePreferencesStore();
      final seedSettings = FakeSettingsController(
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
      final seedController = SudokuController(
        preferencesStore: fakePrefs,
        settingsController: seedSettings,
        gameService: FakeGameService(),
      );
      await seedController.ready;

      final saved = jsonDecode(fakePrefs.savedSession!) as Map<String, dynamic>;
      final correction = (saved['corrections'] as Map<String, dynamic>);
      correction['tokensLeft'] = 5;
      fakePrefs.savedSession = jsonEncode(saved);

      final restoreController = SudokuController(
        preferencesStore: fakePrefs,
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
      await restoreController.ready;

      expect(restoreController.state.correctionsLeft, 3);
    },
  );

  test('Loads entitlement into app state at startup', () async {
    final fakePrefs = FakePreferencesStore(entitlement: Entitlement.premium);
    final controller = SudokuController(preferencesStore: fakePrefs);
    await controller.ready;

    expect(controller.entitlement, Entitlement.premium);
    expect(controller.state.entitlement, Entitlement.premium);
  });

  test('Setting entitlement updates state, persistence, and listeners', () async {
    final fakePrefs = FakePreferencesStore(entitlement: Entitlement.free);
    final controller = SudokuController(preferencesStore: fakePrefs);
    await controller.ready;

    var notifications = 0;
    controller.addListener(() {
      notifications += 1;
    });

    controller.onSetEntitlement(Entitlement.premium);

    expect(controller.entitlement, Entitlement.premium);
    expect(controller.state.entitlement, Entitlement.premium);
    expect(fakePrefs.entitlement, Entitlement.premium);
    expect(notifications, 1);
  });
}
