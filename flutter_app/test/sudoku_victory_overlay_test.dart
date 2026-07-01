import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/victory_autumn_leaves_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_confetti_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_foil_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_star_overlay.dart';

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
  int visualOverlayCount() {
    return find.byType(VictoryFoilOverlay).evaluate().length +
        find.byType(VictoryStarOverlay).evaluate().length +
        find.byType(VictoryConfettiOverlay).evaluate().length +
        find.byType(VictoryAutumnLeavesOverlay).evaluate().length;
  }

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

  testWidgets('premium themed celebration randomly picks one premium overlay', (
    tester,
  ) async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(entitlement: Entitlement.premium),
      gameService: _AlwaysSolvedGameService(),
      settingsController: FakeSettingsController(
        const SettingsState(
          notesMode: false,
          difficulty: 'easy',
          canChangeDifficulty: true,
          canChangePuzzleMode: true,
          styleName: 'Modern',
          contentMode: 'animals',
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
    expect(visualOverlayCount(), 1);
  });

  testWidgets('premium numbers celebration remains foil-only', (tester) async {
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(entitlement: Entitlement.premium),
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
    expect(visualOverlayCount(), 1);
  });

  testWidgets('celebration always has one visual style in every mode', (
    tester,
  ) async {
    const modes = <String>[
      'numbers',
      'animals',
      'instruments',
      'butterflies',
      'shells',
      'old_opera',
    ];
    for (final mode in modes) {
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(
          entitlement: Entitlement.premium,
        ),
        gameService: _AlwaysSolvedGameService(),
        settingsController: FakeSettingsController(
          SettingsState(
            notesMode: false,
            difficulty: 'easy',
            canChangeDifficulty: true,
            canChangePuzzleMode: true,
            styleName: 'Modern',
            contentMode: mode,
            animalStyle: 'simple',
            puzzleMode: 'multi',
          ),
        ),
      );
      await controller.ready;
      addTearDown(controller.dispose);

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

      expect(
        visualOverlayCount(),
        1,
        reason: 'Expected one visual overlay for mode $mode',
      );
    }
  });
}
