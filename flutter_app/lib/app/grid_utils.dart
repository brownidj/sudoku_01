import 'package:flutter_app/domain/types.dart';

class GridUtils {
  Grid gridFromBoard(Board board) {
    return List<List<Digit?>>.generate(
      9,
      (r) => List<Digit?>.generate(9, (c) => board.cellAt(r, c).value),
      growable: false,
    );
  }

  Grid copyGrid(Grid grid) {
    return grid.map((row) => row.toList(growable: false)).toList(growable: false);
  }

}
