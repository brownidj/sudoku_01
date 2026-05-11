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
  canChangePuzzleMode: false,
  styleName: 'Modern',
  contentMode: 'numbers',
  animalStyle: 'simple',
  puzzleMode: 'unique',
);

SudokuController _buildController({FakeGameService? gameService}) {
  return SudokuController(
    preferencesStore: FakePreferencesStore(),
    gameService: gameService ?? FakeGameService(),
    settingsController: FakeSettingsController(_defaultSettings),
  );
}

void main() {
  testWidgets('lock icon is not shown after starting a game', (
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

    expect(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
      findsNothing,
    );
  });

  testWidgets('difficulty remains enabled after first move', (
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

    final difficultyDropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
    );
    expect(difficultyDropdown.onChanged, isNotNull);
    expect(
      find.byKey(const ValueKey<String>('top-controls-config-lock-indicator')),
      findsNothing,
    );
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

  testWidgets('game over swaps help chip with progress chip', (
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
    expect(
      find.byKey(const ValueKey<String>('top-controls-progress-chip')),
      findsNothing,
    );

    controller.onShowSolution();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('top-controls-help-chip')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('top-controls-progress-chip')),
      findsOneWidget,
    );
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

    controller.onShowSolution();
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
