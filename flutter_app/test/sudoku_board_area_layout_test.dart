import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';

UiState _state({String contentMode = 'numbers'}) {
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
    contentMode: contentMode,
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    conflictHintsLeft: 3,
  );
}

void main() {
  testWidgets('board size stays stable regardless of candidate panel state', (
    WidgetTester tester,
  ) async {
    Future<Size> pumpAndBoardSize({
      required bool candidateVisible,
      required List<int> candidateDigits,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 620,
              child: SudokuBoardArea(
                state: _state(contentMode: 'numbers'),
                style: styleModern,
                animalImages: const {},
                noteImagesBySize: const {},
                devicePixelRatio: 2.0,
                candidateVisible: candidateVisible,
                candidateDigits: candidateDigits,
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
      await tester.pumpAndSettle();
      return tester.getSize(find.byType(SudokuBoard));
    }

    final sizeSingleCandidate = await pumpAndBoardSize(
      candidateVisible: true,
      candidateDigits: const [1],
    );
    final sizeManyCandidates = await pumpAndBoardSize(
      candidateVisible: true,
      candidateDigits: const [1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
    final sizeNoCandidatesVisible = await pumpAndBoardSize(
      candidateVisible: false,
      candidateDigits: const [1, 2, 3, 4, 5, 6, 7, 8, 9],
    );

    expect(sizeManyCandidates, sizeSingleCandidate);
    expect(sizeNoCandidatesVisible, sizeSingleCandidate);
  });
}
