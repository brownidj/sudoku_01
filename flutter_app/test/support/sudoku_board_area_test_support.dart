import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';

UiState boardAreaState({
  String puzzleMode = 'unique',
  String difficulty = 'easy',
  int correctionsLeft = 3,
  int conflictHintsLeft = 3,
  Coord? selected,
  String? debugScenarioLabel,
  String contentMode = 'numbers',
  bool premiumActive = false,
  DateTime? puzzleStartedAt,
  DateTime? puzzleFinishedAt,
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
    entitlement: premiumActive ? Entitlement.premium : Entitlement.free,
    premiumActive: premiumActive,
    puzzleStartedAt: puzzleStartedAt,
    puzzleFinishedAt: puzzleFinishedAt,
  );
}
