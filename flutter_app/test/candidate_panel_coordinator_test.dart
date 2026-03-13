import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';

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
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  test(
    'CandidatePanelCoordinator shows panel and enables notes mode when needed',
    () async {
      final service = CandidateSelectionService();
      final coordinator = CandidatePanelCoordinator(service);
      var notesEnabled = false;

      await coordinator.onCellTapped(
        state: _state(cellNotes: const [2, 3]),
        coord: const Coord(0, 0),
        animalLoad: null,
        setNotesMode: (enabled) => notesEnabled = enabled,
      );

      expect(notesEnabled, isTrue);
      expect(service.visible, isTrue);
      expect(service.candidateCoord, const Coord(0, 0));
      expect(service.candidateDigits, contains(0));
    },
  );

  test('CandidatePanelCoordinator hides panel after clear', () {
    final service = CandidateSelectionService();
    final coordinator = CandidatePanelCoordinator(service);
    service.show(const Coord(0, 0), const [2, 3, 0]);

    coordinator.onDigitApplied(digit: 0, nextState: _state());

    expect(service.visible, isFalse);
    expect(service.candidateCoord, isNull);
  });

  test(
    'CandidatePanelCoordinator refreshes for notes-mode digit placement',
    () {
      final service = CandidateSelectionService();
      final coordinator = CandidatePanelCoordinator(service);
      var notifyCount = 0;
      service.addListener(() => notifyCount += 1);
      service.show(const Coord(0, 0), const [2, 3, 0]);
      notifyCount = 0;

      coordinator.onDigitApplied(
        digit: 2,
        nextState: _state(notesMode: true, selected: const Coord(0, 0)),
      );

      expect(service.visible, isTrue);
      expect(notifyCount, 1);
    },
  );
}
