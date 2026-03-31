import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';

UiState _state({
  String puzzleMode = 'multi',
  String difficulty = 'easy',
  int correctionsLeft = 3,
  String? debugScenarioLabel,
}) {
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
    difficulty: difficulty,
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: puzzleMode,
    selected: null,
    gameOver: false,
    correctionsLeft: correctionsLeft,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: debugScenarioLabel,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  testWidgets(
    'main metadata row shows puzzle mode, corrections left, and difficulty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 620,
              child: SudokuBoardArea(
                state: _state(
                  puzzleMode: 'unique',
                  difficulty: 'hard',
                  correctionsLeft: 1,
                ),
                style: styleModern,
                animalImages: const {},
                noteImagesBySize: const {},
                devicePixelRatio: 2.0,
                candidateVisible: false,
                candidateDigits: const [],
                selectedNotes: const {},
                onDigitSelected: (_) {},
                onDigitLongPressed: null,
                onTapCell: (_) {},
                onLongPressCell: (_, __) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('UNIQUE'), findsOneWidget);
      expect(find.text('1 auto-corrects left'), findsOneWidget);
      expect(find.text('HARD'), findsOneWidget);
    },
  );

  testWidgets('long press on corrections label shows tooltip details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: _state(
                puzzleMode: 'unique',
                difficulty: 'medium',
                correctionsLeft: 2,
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, __) {},
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('2 auto-corrects left'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'In this mode you have 2 corrections opportunities. '
        'When you select a tile that has no valid solution, because of an '
        'earlier error, a box will open that allows you to use an automatic '
        'correction.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows debug scenario label when one is loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: _state(
                debugScenarioLabel: 'Debug scenario: corrections exhausted',
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, __) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Debug scenario: corrections exhausted'), findsOneWidget);
  });
}
