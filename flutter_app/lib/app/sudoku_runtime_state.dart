import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuRuntimeState {
  History history;
  CorrectionState correctionState;
  Coord? selected;
  Set<Coord> lastConflicts;
  bool gameOver;
  Set<Coord> incorrectCells;
  Set<Coord> solutionAddedCells;
  Set<Coord> correctCells;
  Grid? solutionGrid;
  Grid? initialGrid;
  String? debugScenarioLabel;
  int correctionNoticeSerial;
  String? correctionNoticeMessage;

  SudokuRuntimeState({
    required this.history,
    required this.correctionState,
    this.selected,
    Set<Coord>? lastConflicts,
    this.gameOver = false,
    Set<Coord>? incorrectCells,
    Set<Coord>? solutionAddedCells,
    Set<Coord>? correctCells,
    this.solutionGrid,
    this.initialGrid,
    this.debugScenarioLabel,
    this.correctionNoticeSerial = 0,
    this.correctionNoticeMessage,
  }) : lastConflicts = lastConflicts ?? <Coord>{},
       incorrectCells = incorrectCells ?? <Coord>{},
       solutionAddedCells = solutionAddedCells ?? <Coord>{},
       correctCells = correctCells ?? <Coord>{};
}
