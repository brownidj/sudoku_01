import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/styles.dart';

class CellRenderModel {
  final Color background;
  final bool showSelection;
  final bool showConflict;
  final bool showIncorrect;
  final bool showCorrect;
  final bool showGiven;
  final bool showSolution;

  const CellRenderModel({
    required this.background,
    required this.showSelection,
    required this.showConflict,
    required this.showIncorrect,
    required this.showCorrect,
    required this.showGiven,
    required this.showSolution,
  });
}

class BoardTheme {
  final BoardStyle style;

  const BoardTheme(this.style);

  CellRenderModel cellModel({
    required CellVm cell,
    required bool gameOver,
    required bool peerRowCol,
    required bool peerBox,
  }) {
    Color bg;
    if (cell.conflicted) {
      bg = style.cellConflict;
    } else if (cell.selected) {
      bg = style.cellSelected;
    } else if (peerRowCol) {
      bg = style.cellPeerRowCol;
    } else if (peerBox) {
      bg = style.cellPeerBox;
    } else {
      bg = style.cellDefault;
    }

    return CellRenderModel(
      background: bg,
      showSelection: !gameOver && cell.selected,
      showConflict: !gameOver && cell.conflicted,
      showIncorrect: gameOver && cell.incorrect,
      showCorrect: gameOver && cell.correct,
      showGiven: gameOver && cell.given,
      showSolution: gameOver && cell.solutionAdded,
    );
  }
}
