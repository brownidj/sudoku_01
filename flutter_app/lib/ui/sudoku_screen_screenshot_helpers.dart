part of 'sudoku_screen.dart';

extension _SudokuScreenScreenshotHelpers on _SudokuScreenState {
  Grid _currentGrid() {
    final board = widget.controller.state.board.cells;
    return List<List<Digit?>>.generate(9, (row) {
      return List<Digit?>.generate(
        9,
        (col) => board[row][col].value,
        growable: false,
      );
    }, growable: false);
  }

  int _emptyCellCount() {
    var count = 0;
    for (final row in widget.controller.state.board.cells) {
      for (final cell in row) {
        if (cell.value == null) {
          count += 1;
        }
      }
    }
    return count;
  }

  Coord? _selectScreenshotCandidateCell() {
    final state = widget.controller.state;
    Coord? bestCoord;
    List<int> bestCandidates = const [];

    for (var row = 0; row < 9; row += 1) {
      for (var col = 0; col < 9; col += 1) {
        final cell = state.board.cells[row][col];
        if (cell.given || cell.value != null) {
          continue;
        }
        final coord = Coord(row, col);
        final digits = _remainingDigitsForBlockForScreenshot(state, coord);
        if (digits.isEmpty) {
          continue;
        }
        if (bestCoord == null ||
            digits.length > bestCandidates.length ||
            (digits.length == bestCandidates.length &&
                _coordPriority(coord) < _coordPriority(bestCoord))) {
          bestCoord = coord;
          bestCandidates = digits;
        }
      }
    }
    return bestCoord;
  }

  List<int> _remainingDigitsForBlockForScreenshot(UiState state, Coord coord) {
    final used = <int>{};
    final blockRowStart = (coord.row ~/ 3) * 3;
    final blockColStart = (coord.col ~/ 3) * 3;
    for (var row = blockRowStart; row < blockRowStart + 3; row += 1) {
      for (var col = blockColStart; col < blockColStart + 3; col += 1) {
        final value = state.board.cells[row][col].value;
        if (value != null) {
          used.add(value);
        }
      }
    }
    return [
      for (var digit = 1; digit <= 9; digit += 1)
        if (!used.contains(digit)) digit,
    ];
  }

  int _coordPriority(Coord coord) {
    return ((coord.row - 4).abs() + (coord.col - 4).abs()) * 100 +
        coord.row * 10 +
        coord.col;
  }

  Coord? _selectNextDeterministicMove(Grid solution) {
    final grid = _currentGrid();
    final candidates = <_ScreenshotBlock>[];
    final preferred = <_ScreenshotBlock>[];

    for (var blockRow = 0; blockRow < 3; blockRow += 1) {
      for (var blockCol = 0; blockCol < 3; blockCol += 1) {
        final empties = <Coord>[];
        for (var row = blockRow * 3; row < blockRow * 3 + 3; row += 1) {
          for (var col = blockCol * 3; col < blockCol * 3 + 3; col += 1) {
            if (grid[row][col] == null) {
              empties.add(Coord(row, col));
            }
          }
        }
        if (empties.isEmpty) {
          continue;
        }
        final block = _ScreenshotBlock(blockRow, blockCol, empties);
        candidates.add(block);
        if (empties.length >= 2) {
          preferred.add(block);
        }
      }
    }

    final pool = preferred.isNotEmpty ? preferred : candidates;
    if (pool.isEmpty) {
      return null;
    }

    pool.sort((a, b) {
      final emptyCompare = a.empties.length.compareTo(b.empties.length);
      if (emptyCompare != 0) {
        return emptyCompare;
      }
      final distanceCompare = a.centerDistance.compareTo(b.centerDistance);
      if (distanceCompare != 0) {
        return distanceCompare;
      }
      final rowCompare = a.blockRow.compareTo(b.blockRow);
      if (rowCompare != 0) {
        return rowCompare;
      }
      return a.blockCol.compareTo(b.blockCol);
    });

    final block = pool.first;
    block.empties.sort((a, b) {
      final rowCompare = a.row.compareTo(b.row);
      if (rowCompare != 0) {
        return rowCompare;
      }
      return a.col.compareTo(b.col);
    });
    return block.empties.firstWhere(
      (coord) => solution[coord.row][coord.col] != null,
      orElse: () => block.empties.first,
    );
  }

  Future<void> _waitForCondition(
    bool Function() predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!predicate()) {
      if (DateTime.now().isAfter(deadline)) {
        throw StateError(
          'Timed out waiting for screenshot state: ${ScreenshotMode.outputFilename}',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }
}

class _ScreenshotBlock {
  final int blockRow;
  final int blockCol;
  final List<Coord> empties;

  const _ScreenshotBlock(this.blockRow, this.blockCol, this.empties);

  int get centerDistance => (blockRow - 1).abs() + (blockCol - 1).abs();
}
