import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/note_layout.dart';

void main() {
  test('noteGridSize uses 2x2 up to 4 notes and 3x3 above', () {
    for (var count = 0; count <= 4; count += 1) {
      expect(noteGridSize(count), 2);
    }
    for (var count = 5; count <= 9; count += 1) {
      expect(noteGridSize(count), 3);
    }
  });

  test('bestNoteSize picks the largest size that fits', () {
    final sizes = [16, 20, 24, 32];
    expect(bestNoteSize(10, sizes), 16);
    expect(bestNoteSize(16, sizes), 16);
    expect(bestNoteSize(19, sizes), 16);
    expect(bestNoteSize(20, sizes), 20);
    expect(bestNoteSize(31, sizes), 24);
    expect(bestNoteSize(32, sizes), 32);
    expect(bestNoteSize(40, sizes), 32);
  });
}
