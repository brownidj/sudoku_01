import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  testWidgets(
    'debug drawer tools are hidden by default and enabled by 7 taps',
    (WidgetTester tester) async {
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

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('Load Correction Scenario'), findsNothing);

      Navigator.of(tester.element(find.byType(SudokuScreen))).maybePop();
      await tester.pumpAndSettle();

      for (var i = 0; i < 7; i += 1) {
        await tester.tap(
          find.byKey(const ValueKey<String>('version-title-text')),
        );
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('Load Correction Scenario'), findsOneWidget);
    },
  );

  testWidgets('debug scenario notification is hidden when debug mode is off', (
    WidgetTester tester,
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

    controller.onLoadCorrectionScenario();
    await tester.pumpAndSettle();
    expect(find.text('Debug scenario: correction available'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 7; i += 1) {
      await tester.tap(
        find.byKey(const ValueKey<String>('version-title-text')),
      );
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();
    expect(find.text('Debug scenario: correction available'), findsOneWidget);
  });

  testWidgets('confirming a correction shows corrected tiles snackbar', (
    WidgetTester tester,
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
    controller.onLoadCorrectionScenario();

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This board is unsatisfiable from an earlier move. Use 1 correction?',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Use correction'));
    await tester.pumpAndSettle();

    expect(find.text('1 tile(s) corrected.'), findsOneWidget);
  });

  testWidgets(
    'locked difficulty shows premium explainer for free entitlement',
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

      await tester.tap(
        find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('MUCH HARDER').last);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('premium-sheet-title')),
        findsOneWidget,
      );
      expect(
        find.textContaining('MUCH HARDER is available in Full Version.'),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('premium-sheet-dismiss-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('EASY'), findsOneWidget);
      expect(gameService.newGameCalls, baselineNewGameCalls);
    },
  );

  testWidgets('changing puzzle mode prompts before starting a new game', (
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

    await tester.tap(
      find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('UNIQUE').last);
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsOneWidget);
    expect(
      find.text('Change puzzle mode to UNIQUE and start a new game?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    expect(find.text('UNIQUE'), findsOneWidget);
    expect(gameService.newGameCalls, greaterThan(baselineNewGameCalls));
  });

  testWidgets('debug reset entitlement action switches version from full to free', (
    WidgetTester tester,
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
    controller.onSetEntitlement(Entitlement.premium);

    await tester.pumpWidget(
      MaterialApp(home: SudokuScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 7; i += 1) {
      await tester.tap(
        find.byKey(const ValueKey<String>('version-title-text')),
      );
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(find.text('Full'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('drawer-reset-entitlement-free')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('drawer-reset-entitlement-free')),
    );
    await tester.pumpAndSettle();
    expect(controller.state.premiumActive, isFalse);

    scaffoldState.openDrawer();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('drawer-premium-status')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('drawer-premium-status')),
        matching: find.text('Free'),
      ),
      findsOneWidget,
    );
  });
}
