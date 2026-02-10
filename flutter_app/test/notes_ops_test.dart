import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/domain/ops.dart' as ops;
import 'package:flutter_app/domain/types.dart';

void main() {
  test('toggleNote allows multiple notes and removes on toggle', () {
    final board = Board.empty();
    final coord = const Coord(0, 0);

    final b1 = ops.toggleNote(board, coord, 1);
    final b2 = ops.toggleNote(b1, coord, 3);

    final notes = b2.cellAtCoord(coord).notes;
    expect(notes.contains(1), isTrue);
    expect(notes.contains(3), isTrue);

    final b3 = ops.toggleNote(b2, coord, 1);
    final notes2 = b3.cellAtCoord(coord).notes;
    expect(notes2.contains(1), isFalse);
    expect(notes2.contains(3), isTrue);
  });

  test('clearNotes clears notes without touching value', () {
    final board = Board.empty();
    final coord = const Coord(0, 0);

    final withNotes = ops.toggleNote(board, coord, 2);
    final cleared = ops.clearNotes(withNotes, coord);

    final cell = cleared.cellAtCoord(coord);
    expect(cell.value, isNull);
    expect(cell.notes.isEmpty, isTrue);
  });
}
