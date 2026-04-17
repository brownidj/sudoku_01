import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/sudoku_content_asset_selector.dart';

UiState _state({required String contentMode, String animalStyle = 'simple'}) {
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
    animalStyle: animalStyle,
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  test('notesForState returns instrument notes in instruments mode', () {
    final instrumentNotes = <int, Map<int, ui.Image>>{16: <int, ui.Image>{}};
    final notesByVariant = <String, Map<int, Map<int, ui.Image>>>{
      'instruments': instrumentNotes,
      'simple': <int, Map<int, ui.Image>>{16: <int, ui.Image>{}},
    };
    final result = SudokuContentAssetSelector.notesForState(
      _state(contentMode: 'instruments'),
      notesByVariant: notesByVariant,
    );

    expect(result, same(instrumentNotes));
  });

  test('notesForState returns style notes in animals mode', () {
    final cuteNotes = <int, Map<int, ui.Image>>{16: <int, ui.Image>{}};
    final notesByVariant = <String, Map<int, Map<int, ui.Image>>>{
      'simple': <int, Map<int, ui.Image>>{16: <int, ui.Image>{}},
      'cute': cuteNotes,
      'instruments': <int, Map<int, ui.Image>>{16: <int, ui.Image>{}},
    };
    final result = SudokuContentAssetSelector.notesForState(
      _state(contentMode: 'animals', animalStyle: 'cute'),
      notesByVariant: notesByVariant,
    );

    expect(result, same(cuteNotes));
  });

  test('notesForState is empty in numbers mode', () {
    final notesByVariant = <String, Map<int, Map<int, ui.Image>>>{
      'instruments': <int, Map<int, ui.Image>>{16: <int, ui.Image>{}},
    };
    final result = SudokuContentAssetSelector.notesForState(
      _state(contentMode: 'numbers'),
      notesByVariant: notesByVariant,
    );

    expect(result, isEmpty);
  });
}
