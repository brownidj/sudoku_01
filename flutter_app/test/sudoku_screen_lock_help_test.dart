import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

import 'support/sudoku_controller_test_support.dart';

const SettingsState _defaultSettings = SettingsState(
  notesMode: false,
  difficulty: 'easy',
  canChangeDifficulty: true,
  canChangePuzzleMode: true,
  styleName: 'Modern',
  contentMode: 'numbers',
  animalStyle: 'simple',
  puzzleMode: 'multi',
);

SudokuController _buildController({FakeGameService? gameService}) {
  return SudokuController(
    preferencesStore: FakePreferencesStore(),
    gameService: gameService ?? FakeGameService(),
    settingsController: FakeSettingsController(_defaultSettings),
  );
}

void main() {
  testWidgets('lock icon tap shows updated lock message', (
    WidgetTester tester,
  ) async {
    final controller = _buildController();
    await controller.ready;

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Difficulty and puzzle mode are locked during a game. To unlock them, either double-tap the lock icon or start a 'New Game'",
      ),
      findsOneWidget,
    );
  });

  testWidgets('double-tap lock prompts and unlocks via new game', (
    WidgetTester tester,
  ) async {
    final gameService = FakeGameService();
    final controller = _buildController(gameService: gameService);
    await controller.ready;

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final puzzleModeDropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
    );
    final difficultyDropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
    );
    expect(puzzleModeDropdown.onChanged, isNull);
    expect(difficultyDropdown.onChanged, isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
    );
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock Settings?'), findsOneWidget);
    expect(
      find.text(
        'Unlocking difficulty and puzzle mode will start a new game and reset this board. Continue?',
      ),
      findsOneWidget,
    );

    final baselineNewGameCalls = gameService.newGameCalls;
    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
    expect(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
      findsNothing,
    );

    final unlockedPuzzleModeDropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
    );
    final unlockedDifficultyDropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
    );
    expect(unlockedPuzzleModeDropdown.onChanged, isNotNull);
    expect(unlockedDifficultyDropdown.onChanged, isNotNull);
  });

  testWidgets('help chip appears in top controls and opens help dialog', (
    WidgetTester tester,
  ) async {
    final controller = _buildController();
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('top-controls-help-chip')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-help-chip')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('holding your finger'), findsOneWidget);
  });

  testWidgets('progress chip opens metrics sheet with completed puzzles', (
    WidgetTester tester,
  ) async {
    final prefs = FakePreferencesStore(completedPuzzles: 7);
    final controller = SudokuController(
      preferencesStore: prefs,
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(_defaultSettings),
    );
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-progress-chip')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.textContaining('Completed puzzles: 7'), findsOneWidget);
    expect(find.textContaining('Days played: coming soon'), findsOneWidget);
    expect(find.textContaining('Streak: coming soon'), findsOneWidget);
  });
}
