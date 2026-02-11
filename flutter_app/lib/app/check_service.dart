import 'package:flutter_app/application/solver.dart';
import 'package:flutter_app/domain/types.dart';

class CheckResult {
  final Set<Coord> incorrect;
  final Set<Coord> correct;
  final Set<Coord> solutionAdded;
  final Grid? solutionGrid;

  const CheckResult({
    required this.incorrect,
    required this.correct,
    required this.solutionAdded,
    required this.solutionGrid,
  });
}

class CheckService {
  CheckResult check({
    required Grid baseGrid,
    required Grid currentGrid,
    required Set<Coord> givens,
    required bool showSolution,
  }) {
    final solved = solveGrid(baseGrid);
    if (solved == null) {
      return const CheckResult(
        incorrect: {},
        correct: {},
        solutionAdded: {},
        solutionGrid: null,
      );
    }

    final incorrect = <Coord>{};
    final correct = <Coord>{};
    final added = <Coord>{};

    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final value = currentGrid[r][c];
        final solvedValue = solved[r][c];
        final coord = Coord(r, c);
        if (value != null && solvedValue != null && value != solvedValue) {
          incorrect.add(coord);
        } else if (value != null && solvedValue != null && value == solvedValue) {
          if (!givens.contains(coord)) {
            correct.add(coord);
          }
        } else if (value == null && solvedValue != null) {
          added.add(coord);
        }
      }
    }

    return CheckResult(
      incorrect: incorrect,
      correct: correct,
      solutionAdded: showSolution ? added : {},
      solutionGrid: showSolution ? solved : null,
    );
  }
}
