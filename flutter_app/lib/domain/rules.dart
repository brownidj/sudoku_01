import 'package:flutter_app/domain/types.dart';

Set<Coord> _coordsInRow(int row) {
  return {for (var c = 0; c < 9; c += 1) Coord(row, c)};
}

Set<Coord> _coordsInCol(int col) {
  return {for (var r = 0; r < 9; r += 1) Coord(r, col)};
}

Set<Coord> _coordsInBox(Coord coord) {
  final br = (coord.row ~/ 3) * 3;
  final bc = (coord.col ~/ 3) * 3;
  return {
    for (var r = br; r < br + 3; r += 1)
      for (var c = bc; c < bc + 3; c += 1) Coord(r, c),
  };
}

Set<Coord> conflictsForCell(Board board, Coord coord) {
  final cell = board.cellAtCoord(coord);
  if (cell.value == null) {
    return {};
  }
  final digit = cell.value!;
  final related = _coordsInRow(coord.row)
    ..addAll(_coordsInCol(coord.col))
    ..addAll(_coordsInBox(coord));
  related.remove(coord);
  final conflicts = <Coord>{};
  for (final other in related) {
    if (board.cellAt(other.row, other.col).value == digit) {
      conflicts.add(other);
    }
  }
  return conflicts;
}

Set<Digit> candidatesForCell(Board board, Coord coord) {
  final cell = board.cellAtCoord(coord);
  if (cell.value != null) {
    return {};
  }

  final used = <Digit>{};
  final related = _coordsInRow(coord.row)
    ..addAll(_coordsInCol(coord.col))
    ..addAll(_coordsInBox(coord));
  related.remove(coord);

  for (final other in related) {
    final value = board.cellAt(other.row, other.col).value;
    if (value != null) {
      used.add(value);
    }
  }

  return {
    for (var digit = 1; digit <= 9; digit += 1)
      if (!used.contains(digit)) digit,
  };
}

Set<Coord> allConflictCoords(Board board) {
  final conflicts = <Coord>{};
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      final coord = Coord(r, c);
      if (board.cellAtCoord(coord).value == null) {
        continue;
      }
      final others = conflictsForCell(board, coord);
      if (others.isNotEmpty) {
        conflicts.add(coord);
        conflicts.addAll(others);
      }
    }
  }
  return conflicts;
}

bool isLegalPlacement(Board board, Coord coord, Digit digit) {
  final cell = board.cellAtCoord(coord);
  if (cell.value == digit) {
    return true;
  }
  if (cell.value != null) {
    return false;
  }
  final related = _coordsInRow(coord.row)
    ..addAll(_coordsInCol(coord.col))
    ..addAll(_coordsInBox(coord));
  related.remove(coord);
  for (final other in related) {
    if (board.cellAt(other.row, other.col).value == digit) {
      return false;
    }
  }
  return true;
}

bool hasAnyConflicts(Board board) {
  return allConflictCoords(board).isNotEmpty;
}

bool isSolved(Board board) {
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      if (board.cellAt(r, c).value == null) {
        return false;
      }
    }
  }
  return !hasAnyConflicts(board);
}
