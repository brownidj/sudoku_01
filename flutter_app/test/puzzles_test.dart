import 'dart:math';

import 'package:flutter_app/application/solver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;

void main() {
  test('Hard mode forces unique when multi is requested', () {
    final puzzle = puzzles.generatePuzzle(
      'hard',
      mode: 'multi',
      rng: Random(7),
    );
    expect(puzzle.difficulty, 'hard');
    expect(puzzle.grid.length, 9);
    for (final row in puzzle.grid) {
      expect(row.length, 9);
    }
    expect(countSolutions(puzzle.grid, limit: 2), 1);
  });

  test('Unique mode generates a single-solution puzzle', () {
    final puzzle = puzzles.generatePuzzle(
      'medium',
      mode: 'unique',
      rng: Random(42),
    );
    expect(countSolutions(puzzle.grid, limit: 2), 1);
  });
}
