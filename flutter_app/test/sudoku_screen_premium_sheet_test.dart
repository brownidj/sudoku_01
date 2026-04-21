import 'package:flutter/material.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  testWidgets('locked drawer premium item opens the reusable premium sheet', (
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

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('drawer-locked-progress-tracker')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('premium-sheet-title')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Progress Tracker is available in Full Version.'),
      findsOneWidget,
    );
    expect(find.text('Not now'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('premium-sheet-unlock-button')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('premium-sheet-dismiss-button')),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('unlock action from premium sheet triggers billing feedback', (
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

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('drawer-unlock-premium')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('premium-sheet-unlock-button')),
    );
    await tester.pump();

    expect(
      find.text('Purchases are unavailable on this device right now.'),
      findsOneWidget,
    );
  });
}
