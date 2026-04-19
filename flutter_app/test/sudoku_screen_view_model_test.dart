import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';

UiState _state({
  bool gameOver = false,
  Coord? selected,
  List<int> notes = const [],
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
        selected: selected == Coord(r, c),
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
  cells[0][0] = CellVm(
    coord: const Coord(0, 0),
    value: null,
    given: false,
    notes: notes,
    selected: selected == const Coord(0, 0),
    conflicted: false,
    incorrect: false,
    solutionAdded: false,
    correct: false,
    reverted: false,
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
    selected: selected,
    gameOver: gameOver,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  test('derives candidate visibility and selected notes', () {
    final selection = CandidateSelectionService();
    final coordinator = CandidatePanelCoordinator(selection);
    selection.show(const Coord(0, 0), const [1, 2]);

    final vm = SudokuScreenViewModel.from(
      state: _state(selected: const Coord(0, 0), notes: const [2, 3]),
      coordinator: coordinator,
      selectionService: selection,
      debugToolsEnabled: true,
    );

    expect(vm.candidateVisible, isTrue);
    expect(vm.candidateDigits, const [1, 2]);
    expect(vm.selectedNotes, {2, 3});
  });

  test('hides candidate panel when game is over', () {
    final selection = CandidateSelectionService();
    final coordinator = CandidatePanelCoordinator(selection);
    selection.show(const Coord(0, 0), const [1]);

    final vm = SudokuScreenViewModel.from(
      state: _state(gameOver: true, selected: const Coord(0, 0)),
      coordinator: coordinator,
      selectionService: selection,
      debugToolsEnabled: true,
    );

    expect(vm.candidateVisible, isFalse);
  });
}
