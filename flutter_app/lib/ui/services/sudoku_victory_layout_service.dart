import 'dart:math' as math;

import 'package:flutter/material.dart';

class SudokuVictoryLayoutService {
  static const double _mascotTopGap = 20;
  static const double _mascotHeight = 96;
  static const double _messageTopGap = 12;
  static const double _messageHeight = 24;
  static const double _overlayTopToCenterY = 173;

  const SudokuVictoryLayoutService();

  double? midpointBetweenTilesAndBottomControls({
    required GlobalKey overlayStackKey,
    required GlobalKey boardKey,
    required GlobalKey bottomControlsKey,
  }) {
    final stackBox =
        overlayStackKey.currentContext?.findRenderObject() as RenderBox?;
    final boardBox = boardKey.currentContext?.findRenderObject() as RenderBox?;
    final controlsBox =
        bottomControlsKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || boardBox == null || controlsBox == null) {
      return null;
    }
    final stackTop = stackBox.localToGlobal(Offset.zero).dy;
    final tilesBottom =
        boardBox.localToGlobal(Offset(0, boardBox.size.height)).dy - stackTop;
    final shortestSide = math.min(stackBox.size.width, stackBox.size.height);
    return computeCenterY(
      shortestSide: shortestSide,
      tilesBottom: tilesBottom,
      controlsTop: controlsBox.localToGlobal(Offset.zero).dy - stackTop,
    );
  }

  double computeCenterY({
    required double shortestSide,
    required double tilesBottom,
    required double controlsTop,
  }) {
    if (controlsTop <= tilesBottom) {
      return tilesBottom + _overlayTopToCenterY;
    }
    final overlayHeight = _mascotHeight + _messageTopGap + _messageHeight;
    final centeredTop = ((tilesBottom + controlsTop) - overlayHeight) / 2;
    final minTop = tilesBottom + _mascotTopGap;
    final overlayTop = math.max(centeredTop, minTop);
    return overlayTop + _overlayTopToCenterY;
  }
}
