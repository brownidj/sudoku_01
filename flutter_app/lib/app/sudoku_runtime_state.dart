import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

const activePlayIdleTimeout = Duration(seconds: 60);

class SudokuRuntimeState {
  History history;
  CorrectionState correctionState;
  Coord? selected;
  Set<Coord> lastConflicts;
  bool gameOver;
  bool puzzleSolved;
  Set<Coord> incorrectCells;
  Set<Coord> solutionAddedCells;
  Set<Coord> correctCells;
  Grid? solutionGrid;
  Grid? initialGrid;
  String? debugScenarioLabel;
  int correctionNoticeSerial;
  String? correctionNoticeMessage;
  int conflictHintsLeft;
  DateTime puzzleStartedAt;
  DateTime? puzzleFinishedAt;
  int activeElapsedSeconds;
  DateTime? activeTimingStartedAt;

  SudokuRuntimeState({
    required this.history,
    required this.correctionState,
    this.selected,
    Set<Coord>? lastConflicts,
    this.gameOver = false,
    this.puzzleSolved = false,
    Set<Coord>? incorrectCells,
    Set<Coord>? solutionAddedCells,
    Set<Coord>? correctCells,
    this.solutionGrid,
    this.initialGrid,
    this.debugScenarioLabel,
    this.correctionNoticeSerial = 0,
    this.correctionNoticeMessage,
    this.conflictHintsLeft = 0,
    DateTime? puzzleStartedAt,
    this.puzzleFinishedAt,
    this.activeElapsedSeconds = 0,
    this.activeTimingStartedAt,
  }) : puzzleStartedAt = puzzleStartedAt ?? DateTime.now(),
       lastConflicts = lastConflicts ?? <Coord>{},
       incorrectCells = incorrectCells ?? <Coord>{},
       solutionAddedCells = solutionAddedCells ?? <Coord>{},
       correctCells = correctCells ?? <Coord>{};
}
