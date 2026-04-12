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
  final withValue = board.withCell(coord, newCell);
  return removePeerNotesForDigit(withValue, coord, value);
}

Board clearNotes(Board board, Coord coord) {
  final cell = board.cellAtCoord(coord);
  if (cell.given) {
    return board;
  }
  if (cell.value != null) {
    return board;
  }
  if (cell.notes.isEmpty) {
    return board;
  }
  final newCell = Cell(value: null, given: false, notes: const {});
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
    notes.remove(digit);
  } else {
    notes.add(digit);
  }
  final newCell = Cell(value: null, given: false, notes: notes);
  if (_cellEquals(newCell, cell)) {
    return board;
  }
  return board.withCell(coord, newCell);
}

Board removePeerNotesForDigit(Board board, Coord coord, Digit digit) {
  var next = board;
  final seen = <Coord>{};

  void removeAt(Coord peer) {
    if (peer == coord || !seen.add(peer)) {
      return;
    }
    final cell = next.cellAtCoord(peer);
    if (cell.value != null ||
        cell.notes.isEmpty ||
        !cell.notes.contains(digit)) {
      return;
    }
    final updatedNotes = cell.notes.toSet()..remove(digit);
    final updatedCell = Cell(
      value: null,
      given: cell.given,
      notes: updatedNotes,
    );
    next = next.withCell(peer, updatedCell);
  }

  for (var c = 0; c < 9; c += 1) {
    removeAt(Coord(coord.row, c));
  }

  for (var r = 0; r < 9; r += 1) {
    removeAt(Coord(r, coord.col));
  }

  final boxRowStart = (coord.row ~/ 3) * 3;
  final boxColStart = (coord.col ~/ 3) * 3;
  for (var r = boxRowStart; r < boxRowStart + 3; r += 1) {
    for (var c = boxColStart; c < boxColStart + 3; c += 1) {
      removeAt(Coord(r, c));
    }
  }

  return next;
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
