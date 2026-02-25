import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;

void main() {
  test('Hard mode forces unique when multi is requested', () {
    final puzzle = puzzles.generatePuzzle('hard', mode: 'multi');
    expect(puzzle.difficulty, 'hard');
    expect(puzzle.grid.length, 9);
    for (final row in puzzle.grid) {
      expect(row.length, 9);
    }
  });
}
