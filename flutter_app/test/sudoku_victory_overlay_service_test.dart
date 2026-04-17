import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';

UiState _state({required String contentMode, required bool puzzleSolved}) {
  final row = List<CellVm>.generate(
    9,
    (index) => CellVm(
      coord: Coord(0, index),
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
  );
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => row
        .asMap()
        .entries
        .map(
          (entry) => CellVm(
            coord: Coord(r, entry.key),
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
        )
        .toList(),
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
    puzzleMode: 'unique',
    selected: null,
    gameOver: puzzleSolved,
    puzzleSolved: puzzleSolved,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    conflictHintsLeft: 0,
  );
}

void main() {
  test('instruments celebration uses an instrument image', () {
    final service = SudokuVictoryOverlayService();
    service.onUiStateChanged(
      _state(contentMode: 'instruments', puzzleSolved: true),
    );

    expect(service.state.value.visible, isTrue);
    expect(
      SudokuVictoryOverlayService.instrumentCelebrationAssets,
      contains(service.state.value.assetPath),
    );
    service.dispose();
  });

  test('numbers celebration may choose from instruments', () {
    final service = SudokuVictoryOverlayService();
    service.onUiStateChanged(
      _state(contentMode: 'numbers', puzzleSolved: true),
    );

    expect(service.state.value.visible, isTrue);
    expect(
      SudokuVictoryOverlayService.numberCelebrationAssets,
      contains(service.state.value.assetPath),
    );
    service.dispose();
  });
}
