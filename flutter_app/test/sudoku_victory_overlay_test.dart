import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/victory_foil_overlay.dart';

import 'support/sudoku_controller_test_support.dart';

class _AlwaysSolvedGameService extends FakeGameService {
  @override
  MoveResult placeDigit(History history, Coord coord, Digit digit) {
    final result = super.placeDigit(history, coord, digit);
    return MoveResult(
      history: result.history,
      conflicts: result.conflicts,
      message: 'Solved.',
      solved: true,
    );
  }
}

void main() {
  testWidgets('shows foil overlay when the player solves the puzzle', (
    tester,
  ) async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: _AlwaysSolvedGameService(),
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

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.state.puzzleSolved, isTrue);
    expect(find.byType(VictoryFoilOverlay), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('victory-cartoon-image')),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 11));
    expect(find.byType(VictoryFoilOverlay), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('victory-cartoon-image')),
      findsNothing,
    );
  });

  testWidgets('does not show foil overlay for check-result game over', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    controller.onCheckSolution();
    await tester.pump();

    expect(controller.state.gameOver, isTrue);
    expect(controller.state.puzzleSolved, isFalse);
    expect(find.byType(VictoryFoilOverlay), findsNothing);
  });

  testWidgets('triple-tapping version title solves and celebrates', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final titleFinder = find.text('ZuDoKu 0.6.2 build 159');
    expect(titleFinder, findsOneWidget);

    await tester.tap(titleFinder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(titleFinder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(titleFinder);
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.state.gameOver, isTrue);
    expect(controller.state.puzzleSolved, isTrue);
    final hasSolutionAdded = controller.state.board.cells
        .expand((row) => row)
        .any((cell) => cell.solutionAdded);
    expect(hasSolutionAdded, isTrue);
    expect(find.byType(VictoryFoilOverlay), findsOneWidget);
  });
}
