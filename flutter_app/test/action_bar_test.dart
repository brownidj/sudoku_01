import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';

UiState _state({bool canUndo = false, bool puzzleSolved = false}) {
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => List<CellVm>.generate(
      9,
      (c) => CellVm(
        coord: Coord(r, c),
        value: null,
        given: false,
        notes: const [],
        selected: false,
        conflicted: false,
        incorrect: false,
        solutionAdded: false,
        correct: false,
        reverted: false,
      ),
      growable: false,
    ),
    growable: false,
  );

  return UiState(
    board: BoardVm(cells: cells),
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: puzzleSolved,
    puzzleSolved: puzzleSolved,
    correctionsLeft: 5,
    canUndo: canUndo,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  testWidgets('Undo button shows tooltip text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Undo'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ActionBar));
    expect(find.text(UiStrings.tooltipUndo(context)), findsOneWidget);
  });

  testWidgets('New game chip shows tooltip text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    await tester.longPress(
      find.byKey(const ValueKey<String>('content-new-game-chip')),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ActionBar));
    expect(find.text(UiStrings.tooltipNewGame(context)), findsOneWidget);
  });

  testWidgets('New game button is visible and triggers callback', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
            onNewGamePressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(ActionBar));
    expect(find.text(UiStrings.actionNewGame(context)), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('content-new-game-chip')),
    );
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('New game button matches notes height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    final newSize = tester.getSize(
      find.byKey(const ValueKey<String>('content-new-game-chip')),
    );
    final notesSize = tester.getSize(
      find.byKey(const ValueKey<String>('action-notes-button')),
    );

    expect(newSize.height, greaterThanOrEqualTo(notesSize.height));
  });

  testWidgets('narrow screens use icon-only labels for clear and undo', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    expect(find.text('⌫'), findsOneWidget);
    expect(find.text('↶'), findsOneWidget);
    expect(find.text('Clear'), findsNothing);
    expect(find.text('Undo'), findsNothing);
  });
}
