import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

import 'support/sudoku_controller_test_support.dart';

Future<FakePreferencesStore> _buildPrefsWithPristineSavedSession() async {
  final prefs = FakePreferencesStore();
  final seed = SudokuController(preferencesStore: prefs);
  await seed.ready;
  await seed.flushGameSession();
  return prefs;
}

void main() {
  testWidgets('new game chip starts immediately when no move has been made', (
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

    final baselineNewGameCalls = gameService.newGameCalls;
    await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsNothing);
    expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
  });

  testWidgets('new game chip prompts after a move and starts on confirmation', (
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

    final baselineNewGameCalls = gameService.newGameCalls;
    final editable = firstEditableCoord(controller.state)!;
    controller.onCellTapped(editable);
    controller.onDigitPressed(1);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsOneWidget);
    expect(
      find.text('Start a fresh game and reset this board?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsNothing);
    expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
  });

  testWidgets('new game chip starts immediately when game is complete', (
    WidgetTester tester,
  ) async {
    final gameService = FakeGameService();
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: gameService,
    );
    await controller.ready;
    controller.onShowSolution();

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final baselineNewGameCalls = gameService.newGameCalls;
    await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsNothing);
    expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
  });

  testWidgets(
    'new game chip prompts for resumed session even before any new move',
    (WidgetTester tester) async {
      final prefs = await _buildPrefsWithPristineSavedSession();
      final gameService = FakeGameService();
      final controller = SudokuController(
        preferencesStore: prefs,
        gameService: gameService,
      );
      await controller.ready;

      expect(controller.hadSavedSessionAtLaunch, isTrue);
      expect(controller.state.canUndo, isFalse);

      await tester.pumpWidget(
        MaterialApp(home: SudokuScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      final baselineNewGameCalls = gameService.newGameCalls;
      await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsOneWidget);
      expect(
        find.text('Start a fresh game and reset this board?'),
        findsOneWidget,
      );
      expect(gameService.newGameCalls, baselineNewGameCalls);

      await tester.tap(find.text('Start New Game'));
      await tester.pumpAndSettle();

      expect(find.text('Start New Game?'), findsNothing);
      expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    },
  );
}
