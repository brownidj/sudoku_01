import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/candidate_selection_controller.dart';

UiState _state({
  bool notesMode = false,
  bool gameOver = false,
  Coord? selected,
  int? cellValue,
  List<int> cellNotes = const [],
  bool cellGiven = false,
  bool cellConflicted = false,
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
    value: cellValue,
    given: cellGiven,
    notes: cellNotes,
    selected: selected == const Coord(0, 0),
    conflicted: cellConflicted,
    incorrect: false,
    solutionAdded: false,
    correct: false,
    reverted: false,
  );
  cells[0][1] = CellVm(
    coord: const Coord(0, 1),
    value: 1,
    given: true,
    notes: const [],
    selected: false,
    conflicted: false,
    incorrect: false,
    solutionAdded: false,
    correct: false,
    reverted: false,
  );

  return UiState(
    board: BoardVm(cells: cells),
    notesMode: notesMode,
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
  );
}

void main() {
  test(
    'CandidatePanelCoordinator shows panel and enables notes mode when needed',
    () async {
      final controller = CandidateSelectionController();
      final coordinator = CandidatePanelCoordinator(controller);
      var notesEnabled = false;

      await coordinator.onCellTapped(
        state: _state(cellNotes: const [2, 3]),
        coord: const Coord(0, 0),
        animalLoad: null,
        setNotesMode: (enabled) => notesEnabled = enabled,
      );

      expect(notesEnabled, isTrue);
      expect(controller.visible, isTrue);
      expect(controller.candidateCoord, const Coord(0, 0));
      expect(controller.candidateDigits, contains(0));
    },
  );

  test('CandidatePanelCoordinator hides panel after clear', () {
    final controller = CandidateSelectionController();
    final coordinator = CandidatePanelCoordinator(controller);
    controller.show(const Coord(0, 0), const [2, 3, 0]);

    coordinator.onDigitApplied(digit: 0, nextState: _state());

    expect(controller.visible, isFalse);
    expect(controller.candidateCoord, isNull);
  });

  test(
    'CandidatePanelCoordinator refreshes for notes-mode digit placement',
    () {
      final controller = CandidateSelectionController();
      final coordinator = CandidatePanelCoordinator(controller);
      var notifyCount = 0;
      controller.addListener(() => notifyCount += 1);
      controller.show(const Coord(0, 0), const [2, 3, 0]);
      notifyCount = 0;

      coordinator.onDigitApplied(
        digit: 2,
        nextState: _state(notesMode: true, selected: const Coord(0, 0)),
      );

      expect(controller.visible, isTrue);
      expect(notifyCount, 1);
    },
  );
}
