import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/application/solver.dart';
import 'package:flutter_app/domain/types.dart';

Grid _emptyGrid() {
  return List<List<Digit?>>.generate(
    9,
    (_) => List<Digit?>.filled(9, null, growable: false),
    growable: false,
  );
}

Grid _copyGrid(Grid grid) {
  return grid.map((row) => row.toList(growable: false)).toList(growable: false);
}

void main() {
  test('check treats any solvable current grid as correct', () {
    final baseGrid = _emptyGrid();
    final solvedBase = solveGrid(baseGrid);
    expect(solvedBase, isNotNull);

    final baseValue = solvedBase![0][0]!;
    int? altValue;
    for (var d = 1; d <= 9; d += 1) {
      if (d == baseValue) {
        continue;
      }
      final candidate = _copyGrid(baseGrid);
      candidate[0][0] = d;
      if (solveGrid(candidate) != null) {
        altValue = d;
        break;
      }
    }

    expect(altValue, isNotNull);

    final currentGrid = _copyGrid(baseGrid);
    currentGrid[0][0] = altValue;

    final result = CheckService().check(
      baseGrid: baseGrid,
      currentGrid: currentGrid,
      givens: const {},
      showSolution: false,
    );

    expect(result.incorrect, isEmpty);
  });

  test('showSolution flags wrong prefilled value against base solution', () {
    final baseGrid = _emptyGrid();
    final solvedBase = solveGrid(baseGrid);
    expect(solvedBase, isNotNull);

    final baseValue = solvedBase![0][0]!;
    final wrongValue = (baseValue % 9) + 1;
    expect(wrongValue, isNot(baseValue));

    final currentGrid = _copyGrid(baseGrid);
    currentGrid[0][0] = wrongValue;

    final result = CheckService().check(
      baseGrid: baseGrid,
      currentGrid: currentGrid,
      givens: const {},
      showSolution: true,
    );

    expect(result.solutionGrid, isNotNull);
    expect(result.incorrect.contains(const Coord(0, 0)), isTrue);
  });
}
