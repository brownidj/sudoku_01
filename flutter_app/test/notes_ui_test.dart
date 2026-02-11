import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';

Future<void> _tapCell(WidgetTester tester, int row, int col) async {
  final rect = tester.getRect(find.byType(SudokuBoard));
  final cellSize = rect.width / 9.0;
  final offset = rect.topLeft + Offset(cellSize * (col + 0.5), cellSize * (row + 0.5));
  await tester.tapAt(offset);
  await tester.pumpAndSettle();
}

Coord _findEditableCell(SudokuController controller) {
  final cells = controller.state.board.cells;
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      if (!cells[r][c].given) {
        return Coord(r, c);
      }
    }
  }
  return const Coord(0, 0);
}

Finder _candidateDigitFinder() {
  return find.descendant(
    of: find.byType(CandidatePanel),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          RegExp(r'^[1-9]$').hasMatch(widget.data!),
    ),
  );
}

Finder _candidateButtonFor(Finder textFinder) {
  return find.ancestor(of: textFinder, matching: find.byType(ElevatedButton));
}

void main() {
  testWidgets('tapping a noted cell enables notes mode', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    final controller = SudokuController();
    controller.onContentModeChanged('numbers');
    controller.setNotesMode(true);
    final coord = _findEditableCell(controller);
    controller.onCellTapped(coord);
    controller.onDigitPressed(1);
    controller.setNotesMode(false);

    await tester.pumpWidget(MaterialApp(home: SudokuScreen(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.byType(SudokuBoard), findsOneWidget);
    await _tapCell(tester, coord.row, coord.col);

    expect(controller.state.notesMode, isTrue);
  });

  testWidgets('long-pressing a candidate inserts the value in notes mode',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    final controller = SudokuController();
    controller.onContentModeChanged('numbers');
    controller.setNotesMode(true);

    await tester.pumpWidget(MaterialApp(home: SudokuScreen(controller: controller)));
    await tester.pumpAndSettle();

    final coord = _findEditableCell(controller);
    await _tapCell(tester, coord.row, coord.col);
    final candidateFinder = _candidateDigitFinder();
    expect(candidateFinder, findsWidgets);
    final buttonFinder = _candidateButtonFor(candidateFinder.first);
    expect(buttonFinder, findsWidgets);
    await tester.longPress(buttonFinder.first);
    await tester.pumpAndSettle();

    final cell = controller.state.board.cells[coord.row][coord.col];
    expect(cell.value, isNotNull);
    expect(cell.notes, isEmpty);
  });
}
