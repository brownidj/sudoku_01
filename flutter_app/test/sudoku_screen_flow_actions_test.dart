import 'package:flutter/material.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_screen_flow_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  testWidgets('locked difficulty routes to premium explainer sheet', (
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
    const actions = SudokuScreenFlowActions();

    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final pending = actions.requestDifficultyChange(
      context: context,
      isMounted: () => true,
      controller: controller,
      difficulty: 'hard',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('premium-sheet-title')),
      findsOneWidget,
    );
    expect(
      find.textContaining('MUCH HARDER is available in Full Version.'),
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
    await pending;
    expect(controller.state.difficulty, 'easy');
  });

  testWidgets('unlocked difficulty routes to normal change flow', (
    WidgetTester tester,
  ) async {
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
    );
    await controller.ready;
    const actions = SudokuScreenFlowActions();

    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final pending = actions.requestDifficultyChange(
      context: context,
      isMounted: () => true,
      controller: controller,
      difficulty: 'hard',
    );
    await tester.pumpAndSettle();

    expect(find.text('Start New Game?'), findsOneWidget);
    expect(
      find.text('Change difficulty to MUCH HARDER and start a new game?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await pending;
  });
}
