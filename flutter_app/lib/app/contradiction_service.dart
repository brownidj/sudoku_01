import 'package:flutter_app/domain/rules.dart' as rules;
import 'package:flutter_app/domain/types.dart';

class ContradictionAnalysis {
  final Set<Coord> duplicateCells;
  final Set<Coord> deadCells;

  const ContradictionAnalysis({
    required this.duplicateCells,
    required this.deadCells,
  });

  bool get hasContradiction =>
      duplicateCells.isNotEmpty || deadCells.isNotEmpty;

  Set<Coord> get contradictionCells => {...duplicateCells, ...deadCells};
}

class ContradictionService {
  const ContradictionService();

  ContradictionAnalysis analyze(Board board) {
    final deadCells = <Coord>{};
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        if (board.cellAtCoord(coord).value != null) {
          continue;
        }
        if (rules.candidatesForCell(board, coord).isEmpty) {
          deadCells.add(coord);
        }
      }
    }

    return ContradictionAnalysis(
      duplicateCells: rules.allConflictCoords(board),
      deadCells: deadCells,
    );
  }
}
