import 'package:flutter/material.dart';

class SudokuVictoryLayoutService {
  const SudokuVictoryLayoutService();

  double? midpointBetweenTilesAndBottomControls({
    required GlobalKey overlayStackKey,
    required GlobalKey tilesPanelKey,
    required GlobalKey bottomControlsKey,
  }) {
    final stackBox =
        overlayStackKey.currentContext?.findRenderObject() as RenderBox?;
    final tilesBox =
        tilesPanelKey.currentContext?.findRenderObject() as RenderBox?;
    final controlsBox =
        bottomControlsKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || tilesBox == null || controlsBox == null) {
      return null;
    }
    final stackTop = stackBox.localToGlobal(Offset.zero).dy;
    final tilesBottom =
        tilesBox.localToGlobal(Offset(0, tilesBox.size.height)).dy - stackTop;
    final controlsBottom =
        controlsBox.localToGlobal(Offset(0, controlsBox.size.height)).dy -
        stackTop;
    if (controlsBottom <= tilesBottom) {
      return tilesBottom;
    }
    return (tilesBottom + controlsBottom) / 2;
  }
}
