import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

typedef SchemaMap = Map<String, dynamic>;

SchemaMap serializeHistory(History history) {
  return {
    'schema': 'sudoku.save.v1',
    'past': history.past.map(serializeGameState).toList(growable: false),
    'present': serializeGameState(history.present),
    'future': history.future.map(serializeGameState).toList(growable: false),
  };
}

History deserializeHistory(SchemaMap data) {
  _requireSchema(data, expected: 'sudoku.save.v1');
  final past = _requireList(data, 'past')
      .map((entry) => deserializeGameState(_requireMap(entry)))
      .toList(growable: false);
  final present = deserializeGameState(_requireMap(data['present']));
  final future = _requireList(data, 'future')
      .map((entry) => deserializeGameState(_requireMap(entry)))
      .toList(growable: false);
  return History(past: past, present: present, future: future);
}

SchemaMap serializeGameState(GameState state) {
  return {
    'board': serializeBoard(state.board),
    'extras': <String, dynamic>{},
  };
}

GameState deserializeGameState(SchemaMap data) {
  final board = deserializeBoard(_requireMap(data['board']));
  return GameState(board: board);
}

SchemaMap serializeBoard(Board board) {
  final rows = <List<SchemaMap>>[];
  for (var r = 0; r < 9; r += 1) {
    final row = <SchemaMap>[];
    for (var c = 0; c < 9; c += 1) {
      row.add(serializeCell(board.cellAt(r, c)));
    }
    rows.add(row);
  }
  return {'rows': rows};
}

Board deserializeBoard(SchemaMap data) {
  final rows = _requireList(data, 'rows');
  if (rows.length != 9) {
    throw ArgumentError('Board must have 9 rows');
  }
  final cellRows = <List<Cell>>[];
  for (final row in rows) {
    if (row is! List || row.length != 9) {
      throw ArgumentError('Each board row must be a list of 9 cells');
    }
    final cellRow = <Cell>[];
    for (final cellData in row) {
      if (cellData is! Map) {
        throw ArgumentError('Cell must be an object');
      }
      cellRow.add(deserializeCell(_requireMap(cellData)));
    }
    cellRows.add(cellRow);
  }
  return Board(cells: cellRows);
}

SchemaMap serializeCell(Cell cell) {
  final notes = cell.notes.toList()..sort();
  return {
    'value': cell.value,
    'given': cell.given,
    'notes': notes,
  };
}

Cell deserializeCell(SchemaMap data) {
  final value = data['value'];
  Digit? digit;
  if (value == null) {
    digit = null;
  } else if (value is int && value >= 1 && value <= 9) {
    digit = value;
  } else {
    throw ArgumentError('Cell value must be 1..9 or null');
  }
  final given = data['given'] == true;
  final notesRaw = data['notes'];
  if (notesRaw != null && notesRaw is! List) {
    throw ArgumentError('Cell notes must be a list');
  }
  final notes = <Digit>{};
  for (final entry in (notesRaw ?? const [])) {
    if (entry is! int || entry < 1 || entry > 9) {
      throw ArgumentError('Each note must be 1..9');
    }
    notes.add(entry);
  }
  return Cell(value: digit, given: given, notes: notes);
}

void _requireSchema(SchemaMap data, {required String expected}) {
  final schema = data['schema'];
  if (schema != expected) {
    throw ArgumentError('Unsupported save schema: $schema');
  }
}

SchemaMap _requireMap(dynamic value) {
  if (value is! Map) {
    throw ArgumentError('Expected object');
  }
  return Map<String, dynamic>.from(value);
}

List<dynamic> _requireList(SchemaMap data, String key) {
  final value = data[key];
  if (value is! List) {
    throw ArgumentError('Expected list for key: $key');
  }
  return value;
}
