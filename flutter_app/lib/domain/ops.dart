import 'package:flutter_app/domain/types.dart';

Board setValue(Board board, Coord coord, Digit? value) {
  final cell = board.cellAtCoord(coord);
  if (cell.given) {
    return board;
  }
  if (value == null) {
    final newCell = Cell(value: null, given: false, notes: cell.notes);
    if (_cellEquals(newCell, cell)) {
      return board;
    }
    return board.withCell(coord, newCell);
  }
  final newCell = Cell(value: value, given: false, notes: const {});
  if (_cellEquals(newCell, cell)) {
    return board;
  }
  return board.withCell(coord, newCell);
}

Board clearValue(Board board, Coord coord) {
  return setValue(board, coord, null);
}

Board toggleNote(Board board, Coord coord, Digit digit) {
  final cell = board.cellAtCoord(coord);
  if (cell.given) {
    return board;
  }
  if (cell.value != null) {
    return board;
  }
  final notes = cell.notes.toSet();
  if (notes.contains(digit)) {
    notes.clear();
  } else {
    notes
      ..clear()
      ..add(digit);
  }
  final newCell = Cell(value: null, given: false, notes: notes);
  if (_cellEquals(newCell, cell)) {
    return board;
  }
  return board.withCell(coord, newCell);
}

bool _cellEquals(Cell a, Cell b) {
  if (a.value != b.value) {
    return false;
  }
  if (a.given != b.given) {
    return false;
  }
  if (a.notes.length != b.notes.length) {
    return false;
  }
  for (final note in a.notes) {
    if (!b.notes.contains(note)) {
      return false;
    }
  }
  return true;
}
