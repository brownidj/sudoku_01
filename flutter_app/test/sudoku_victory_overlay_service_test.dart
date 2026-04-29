import 'dart:math' as math;

import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_test/flutter_test.dart';

UiState _state({required bool puzzleSolved, required String contentMode}) {
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
    gameOver: puzzleSolved,
    puzzleSolved: puzzleSolved,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  test('old opera puzzle completion selects old opera celebration asset', () {
    final service = SudokuVictoryOverlayService(
      duration: const Duration(seconds: 1),
      random: math.Random(0),
    );
    addTearDown(service.dispose);

    service.onUiStateChanged(
      _state(puzzleSolved: false, contentMode: 'old_opera'),
    );
    service.onUiStateChanged(
      _state(puzzleSolved: true, contentMode: 'old_opera'),
    );

    final selectedAsset = service.state.value.assetPath;
    expect(service.state.value.visible, isTrue);
    expect(selectedAsset, isNotNull);
    expect(
      SudokuVictoryOverlayService.oldOperaCelebrationAssets.contains(
        selectedAsset,
      ),
      isTrue,
    );
  });
}
