import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';

UiState _state({
  required String contentMode,
  bool gameOver = false,
  List<List<CellVm>>? cells,
}) {
  final boardCells =
      cells ??
      List<List<CellVm>>.generate(
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
    board: BoardVm(cells: boardCells),
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: contentMode,
    animalStyle: 'simple',
    puzzleMode: 'unique',
    selected: null,
    gameOver: gameOver,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    conflictHintsLeft: 3,
  );
}

CellVm _cell(
  int row,
  int col, {
  int? value,
  bool given = false,
  List<int> notes = const [],
  bool selected = false,
  bool conflicted = false,
  bool incorrect = false,
  bool solutionAdded = false,
  bool correct = false,
  bool reverted = false,
}) {
  return CellVm(
    coord: Coord(row, col),
    value: value,
    given: given,
    notes: notes,
    selected: selected,
    conflicted: conflicted,
    incorrect: incorrect,
    solutionAdded: solutionAdded,
    correct: correct,
    reverted: reverted,
  );
}

Future<ui.Image> _solidImage(Color color, {int size = 24}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = color,
  );
  return recorder.endRecording().toImage(size, size);
}

Future<void> _pumpBoard(
  WidgetTester tester, {
  required UiState state,
  required Map<int, ui.Image> animalImages,
}) async {
  await tester.binding.setSurfaceSize(const Size(320, 360));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: const ValueKey<String>('board-golden'),
            child: SizedBox(
              width: 270,
              height: 270,
              child: SudokuBoard(
                state: state,
                style: styleModern,
                animalImages: animalImages,
                noteImagesBySize: const {},
                devicePixelRatio: 1.0,
                onTapCell: (_) {},
                onLongPressCell: (_, __) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('golden: numbers mode board', (WidgetTester tester) async {
    final cells = List<List<CellVm>>.generate(
      9,
      (r) => List<CellVm>.generate(9, (c) => _cell(r, c), growable: false),
      growable: false,
    );
    cells[0][0] = _cell(0, 0, value: 1, given: true);
    cells[1][1] = _cell(1, 1, value: 2);
    cells[2][2] = _cell(2, 2, notes: const [1, 2, 3]);

    await _pumpBoard(
      tester,
      state: _state(contentMode: 'numbers', cells: cells),
      animalImages: const {},
    );

    await expectLater(
      find.byKey(const ValueKey<String>('board-golden')),
      matchesGoldenFile('goldens/sudoku_board_numbers_mode.png'),
    );
  });

  testWidgets('golden: instruments mode board', (WidgetTester tester) async {
    final cells = List<List<CellVm>>.generate(
      9,
      (r) => List<CellVm>.generate(9, (c) => _cell(r, c), growable: false),
      growable: false,
    );
    cells[0][0] = _cell(0, 0, value: 1, given: true);
    cells[1][1] = _cell(1, 1, value: 2);
    cells[2][2] = _cell(2, 2, notes: const [1, 2, 3]);

    await _pumpBoard(
      tester,
      state: _state(contentMode: 'instruments', cells: cells),
      animalImages: const {},
    );

    await expectLater(
      find.byKey(const ValueKey<String>('board-golden')),
      matchesGoldenFile('goldens/sudoku_board_instruments_mode.png'),
    );
  });

  testWidgets('golden: animals mode board', (WidgetTester tester) async {
    final cells = List<List<CellVm>>.generate(
      9,
      (r) => List<CellVm>.generate(9, (c) => _cell(r, c), growable: false),
      growable: false,
    );
    cells[0][0] = _cell(0, 0, value: 1, given: true);
    cells[1][1] = _cell(1, 1, value: 2);
    cells[2][2] = _cell(2, 2, notes: const [1, 2, 3]);
    final animalImages = <int, ui.Image>{
      for (var d = 1; d <= 9; d += 1)
        d: await _solidImage(Color(0xFF000000 + d * 0x00111111)),
    };

    await _pumpBoard(
      tester,
      state: _state(contentMode: 'animals', cells: cells),
      animalImages: animalImages,
    );

    await expectLater(
      find.byKey(const ValueKey<String>('board-golden')),
      matchesGoldenFile('goldens/sudoku_board_animals_mode.png'),
    );
  });

  testWidgets('golden: game-over highlight states', (
    WidgetTester tester,
  ) async {
    final cells = List<List<CellVm>>.generate(
      9,
      (r) => List<CellVm>.generate(9, (c) => _cell(r, c), growable: false),
      growable: false,
    );
    cells[0][0] = _cell(0, 0, value: 1, incorrect: true);
    cells[0][1] = _cell(0, 1, value: 2, solutionAdded: true);
    cells[0][2] = _cell(0, 2, value: 3, given: true);
    cells[0][3] = _cell(0, 3, value: 4, correct: true);

    await _pumpBoard(
      tester,
      state: _state(contentMode: 'numbers', gameOver: true, cells: cells),
      animalImages: const {},
    );

    await expectLater(
      find.byKey(const ValueKey<String>('board-golden')),
      matchesGoldenFile('goldens/sudoku_board_game_over_highlights.png'),
    );
  });
}
