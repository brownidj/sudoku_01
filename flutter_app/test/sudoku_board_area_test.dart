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
  int conflictHintsLeft = 3,
  Coord? selected,
  String? debugScenarioLabel,
  String contentMode = 'numbers',
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
    contentMode: contentMode,
    animalStyle: 'simple',
    puzzleMode: puzzleMode,
    selected: selected,
    gameOver: false,
    correctionsLeft: correctionsLeft,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: debugScenarioLabel,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    conflictHintsLeft: conflictHintsLeft,
  );
}

void main() {
  testWidgets(
    'main metadata row shows puzzle mode, hints, corrections left, and difficulty',
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
                  conflictHintsLeft: 2,
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
      expect(find.text('Hints: 2'), findsOneWidget);
      expect(find.text('Corrections: 1'), findsOneWidget);
      expect(find.text('MUCH HARDER'), findsOneWidget);
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

    await tester.longPress(find.text('Corrections: 2'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You have 2 automatic corrections available for this puzzle. '
        'If an earlier move blocks your progress, you can use a correction to keep going '
        'at your own pace. If you run out of corrections, use Undo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('long press on hints label shows tooltip details', (
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
                difficulty: 'easy',
                conflictHintsLeft: 3,
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

    await tester.longPress(find.text('Hints: 3'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Hints mark conflicts in the same row, column, or 3x3 box. Use them to allow you to progress. Use Undo if you have no more Hints',
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

  testWidgets('does not render inline start instruction banner', (
    WidgetTester tester,
  ) async {
    const message = 'To start, select a square you want to add an icon to.';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: _state(selected: null),
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
    expect(find.text(message), findsNothing);
  });

  testWidgets(
    'instruments candidate long press shows instrument name tooltip',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 620,
              child: SudokuBoardArea(
                state: _state(contentMode: 'instruments'),
                style: styleModern,
                animalImages: const {},
                noteImagesBySize: const {},
                devicePixelRatio: 2.0,
                candidateVisible: true,
                candidateDigits: const [1],
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

      expect(find.text('P'), findsOneWidget);
      await tester.longPress(find.text('P'));
      await tester.pumpAndSettle();

      expect(find.text('piano'), findsOneWidget);
      expect(find.text('ape'), findsNothing);
    },
  );
}
