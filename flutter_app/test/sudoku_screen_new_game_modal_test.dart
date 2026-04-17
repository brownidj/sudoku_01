import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  testWidgets(
    'changing difficulty after check/solution bypasses confirmation and starts new game',
    (WidgetTester tester) async {
      final gameService = FakeGameService();
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: gameService,
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

      await tester.pumpWidget(
        MaterialApp(home: SudokuScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      final baselineNewGameCalls = gameService.newGameCalls;
      controller.onCheckSolution();
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('HARD').last);
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsNothing);
      expect(find.text('HARD'), findsOneWidget);
      expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    },
  );

  testWidgets(
    'changing puzzle mode after check/solution bypasses confirmation and starts new game',
    (WidgetTester tester) async {
      final gameService = FakeGameService();
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: gameService,
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

      await tester.pumpWidget(
        MaterialApp(home: SudokuScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      final baselineNewGameCalls = gameService.newGameCalls;
      controller.onCheckSolution();
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('UNIQUE').last);
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsNothing);
      expect(find.text('UNIQUE'), findsOneWidget);
      expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    },
  );

  testWidgets(
    'difficulty modal confirmation starts a new game even after controls are locked',
    (WidgetTester tester) async {
      final gameService = FakeGameService();
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: gameService,
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

      await tester.pumpWidget(
        MaterialApp(home: SudokuScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      final baselineNewGameCalls = gameService.newGameCalls;
      final editable = firstEditableCoord(controller.state)!;
      controller.onCellTapped(editable);
      controller.onDigitPressed(1);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('HARD').last);
      await tester.pumpAndSettle();
      expect(find.text('Start New Game?'), findsOneWidget);

      await tester.tap(find.text('Start New Game'));
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsNothing);
      expect(find.text('HARD'), findsOneWidget);
      expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    },
  );

  testWidgets(
    'puzzle mode modal confirmation starts a new game even after controls are locked',
    (WidgetTester tester) async {
      final gameService = FakeGameService();
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        gameService: gameService,
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

      await tester.pumpWidget(
        MaterialApp(home: SudokuScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      final baselineNewGameCalls = gameService.newGameCalls;
      final editable = firstEditableCoord(controller.state)!;
      controller.onCellTapped(editable);
      controller.onDigitPressed(1);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('UNIQUE').last);
      await tester.pumpAndSettle();
      expect(find.text('Start New Game?'), findsOneWidget);

      await tester.tap(find.text('Start New Game'));
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsNothing);
      expect(find.text('UNIQUE'), findsOneWidget);
      expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    },
  );

  testWidgets('top lock indicator is tappable and shows explainer sheet', (
    WidgetTester tester,
  ) async {
    final gameService = FakeGameService();
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: gameService,
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

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final editable = firstEditableCoord(controller.state)!;
    controller.onCellTapped(editable);
    controller.onDigitPressed(1);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Board Settings Locked'), findsOneWidget);
    expect(
      find.text(
        'Difficulty and puzzle mode are locked for this board. Start a new game when you are ready to change them.',
      ),
      findsOneWidget,
    );
  });
}
