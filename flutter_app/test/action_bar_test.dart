import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';

UiState _state({bool canUndo = false}) {
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
    gameOver: false,
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

    expect(find.text(ActionBar.undoTooltip), findsOneWidget);
  });

  testWidgets('Solution button shows tooltip text', (
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

    await tester.longPress(find.text('Solution'));
    await tester.pumpAndSettle();

    expect(find.text(ActionBar.solutionTooltip), findsOneWidget);
  });
}
