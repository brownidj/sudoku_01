import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/domain/types.dart';

class BoardLayout {
  final double originX;
  final double originY;
  final double cellSize;
  final double boardSize;

  const BoardLayout({
    required this.originX,
    required this.originY,
    required this.cellSize,
    required this.boardSize,
  });
}

BoardLayout layoutForSize(Size size) {
  final boardSize = min(size.width, size.height);
  final originX = (size.width - boardSize) / 2.0;
  final originY = (size.height - boardSize) / 2.0;
  final cellSize = boardSize / 9.0;
  return BoardLayout(
    originX: originX,
    originY: originY,
    cellSize: cellSize,
    boardSize: boardSize,
  );
}

Coord? coordFromOffset(BoardLayout layout, Offset offset) {
  final x = offset.dx;
  final y = offset.dy;
  if (x < layout.originX || y < layout.originY) {
    return null;
  }
  final relX = x - layout.originX;
  final relY = y - layout.originY;
  if (relX < 0 || relY < 0 || relX >= layout.boardSize || relY >= layout.boardSize) {
    return null;
  }
  final col = relX ~/ layout.cellSize;
  final row = relY ~/ layout.cellSize;
  if (row < 0 || row > 8 || col < 0 || col > 8) {
    return null;
  }
  return Coord(row, col);
}
