import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class SolutionCheckOutcome {
  final Set<Coord> incorrect;
  final Set<Coord> correct;
  final Set<Coord> solutionAdded;
  final Grid? solutionGrid;

  const SolutionCheckOutcome({
    required this.incorrect,
    required this.correct,
    required this.solutionAdded,
    required this.solutionGrid,
  });
}

class SolutionCheckCoordinator {
  final CheckService _checkService;
  final GridUtils _gridUtils;

  const SolutionCheckCoordinator(this._checkService, this._gridUtils);

  SolutionCheckOutcome check({
    required History history,
    required Grid? initialGrid,
    required Set<Coord> givens,
  }) {
    final base = initialGrid ?? _gridUtils.gridFromBoard(history.present.board);
    final current = _gridUtils.gridFromBoard(history.present.board);
    final result = _checkService.check(
      baseGrid: base,
      currentGrid: current,
      givens: givens,
      showSolution: false,
    );
    return SolutionCheckOutcome(
      incorrect: result.incorrect,
      correct: result.correct,
      solutionAdded: const {},
      solutionGrid: null,
    );
  }

  SolutionCheckOutcome showSolution({
    required History history,
    required Grid? initialGrid,
    required Set<Coord> givens,
  }) {
    final base = initialGrid ?? _gridUtils.gridFromBoard(history.present.board);
    final current = _gridUtils.gridFromBoard(history.present.board);
    final result = _checkService.check(
      baseGrid: base,
      currentGrid: current,
      givens: givens,
      showSolution: true,
    );
    return SolutionCheckOutcome(
      incorrect: const {},
      correct: result.correct,
      solutionAdded: {...result.solutionAdded, ...result.incorrect},
      solutionGrid: result.solutionGrid,
    );
  }
}
