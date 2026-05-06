import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';
import 'package:flutter_test/flutter_test.dart';

UiState _state() {
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
    contentMode: 'animals',
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    puzzleSolved: false,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  testWidgets('content mode dropdown shows updated labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopControls(
            state: _state(),
            onProgressPressed: () {},
            onHelpPressed: () {},
            onContentModeChanged: (_) {},
            onConfigurationLockTapped: () {},
            onConfigurationLockDoubleTapped: () {},
            onStyleChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Instruments (tricky)'), findsOneWidget);
    expect(find.text('Butterflies (pretty!)'), findsOneWidget);
    expect(find.text('Opera (more tricky)'), findsOneWidget);
  });
}
