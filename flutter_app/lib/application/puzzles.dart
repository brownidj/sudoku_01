import 'dart:math';

import 'package:flutter_app/domain/types.dart';

class Puzzle {
  final String puzzleId;
  final String difficulty;
  final Grid grid;

  const Puzzle({
    required this.puzzleId,
    required this.difficulty,
    required this.grid,
  });
}

const Grid _easyGrid01 = [
  [5, 3, null, null, 7, null, null, null, null],
  [6, null, null, 1, 9, 5, null, null, null],
  [null, 9, 8, null, null, null, null, 6, null],
  [8, null, null, null, 6, null, null, null, 3],
  [4, null, null, 8, null, 3, null, null, 1],
  [7, null, null, null, 2, null, null, null, 6],
  [null, 6, null, null, null, null, 2, 8, null],
  [null, null, null, 4, 1, 9, null, null, 5],
  [null, null, null, null, 8, null, null, 7, 9],
];

const Grid _mediumGrid01 = [
  [null, null, 3, null, 2, null, 6, null, null],
  [9, null, null, 3, null, 5, null, null, 1],
  [null, null, 1, 8, null, 6, 4, null, null],
  [null, null, 8, 1, null, 2, 9, null, null],
  [7, null, null, null, null, null, null, null, 8],
  [null, null, 6, 7, null, 8, 2, null, null],
  [null, null, 2, 6, null, 9, 5, null, null],
  [8, null, null, 2, null, 3, null, null, 9],
  [null, null, 5, null, 1, null, 3, null, null],
];

const Grid _hardGrid01 = [
  [null, null, null, null, null, null, null, 1, 2],
  [null, null, null, null, 3, 5, null, null, null],
  [null, null, null, 7, null, null, 3, null, null],
  [null, 3, null, null, null, null, null, null, null],
  [1, null, null, null, null, null, null, null, 6],
  [null, null, null, null, null, null, null, 7, null],
  [null, null, 5, null, null, 8, null, null, null],
  [null, null, null, 2, 9, null, null, null, null],
  [7, 2, null, null, null, null, null, null, null],
];

const Map<String, List<Grid>> _difficultySeeds = {
  'easy': [_easyGrid01],
  'medium': [_mediumGrid01],
  'hard': [_hardGrid01],
};

const Map<String, int> _targetGivens = {
  'easy': 40,
  'medium': 32,
  'hard': 26,
};

final Map<String, Puzzle> puzzles = {
  'starter': Puzzle(puzzleId: 'starter', difficulty: 'easy', grid: _easyGrid01),
};

Puzzle getPuzzle(String puzzleId) {
  final puzzle = puzzles[puzzleId];
  if (puzzle == null) {
    throw ArgumentError('Unknown puzzle id: $puzzleId');
  }
  return puzzle;
}

List<Puzzle> listPuzzles() => puzzles.values.toList(growable: false);

Puzzle generatePuzzle(String difficulty, {Random? rng}) {
  final random = rng ?? Random();
  final diff = difficulty.trim().toLowerCase();
  if (!_difficultySeeds.containsKey(diff)) {
    throw ArgumentError('Unknown difficulty: $difficulty');
  }
  final solution = _generateFullSolution(random);
  final grid = _maskSolution(solution, diff, random);
  final puzzleId = '${diff}_gen_${random.nextInt(0xffffffff).toRadixString(16).padLeft(8, '0')}';
  return Puzzle(puzzleId: puzzleId, difficulty: diff, grid: grid);
}

Puzzle generateRandomStarter({Random? rng}) {
  return generatePuzzle('easy', rng: rng);
}

Grid randomizeSeed(Grid seed, Random rng) {
  final perm = List<int>.generate(9, (index) => index + 1)..shuffle(rng);
  final digitMap = {for (var d = 1; d <= 9; d += 1) d: perm[d - 1]};

  final bands = [0, 1, 2]..shuffle(rng);
  final rowOrder = <int>[];
  for (final band in bands) {
    final rows = [0, 1, 2]..shuffle(rng);
    rowOrder.addAll(rows.map((r) => band * 3 + r));
  }

  final stacks = [0, 1, 2]..shuffle(rng);
  final colOrder = <int>[];
  for (final stack in stacks) {
    final cols = [0, 1, 2]..shuffle(rng);
    colOrder.addAll(cols.map((c) => stack * 3 + c));
  }

  final newRows = <List<Digit?>>[];
  for (final r in rowOrder) {
    final row = <Digit?>[];
    for (final c in colOrder) {
      final value = seed[r][c];
      row.add(value == null ? null : digitMap[value]);
    }
    newRows.add(row);
  }
  return newRows;
}

Grid _generateFullSolution(Random rng) {
  final work = List<List<Digit?>>.generate(
    9,
    (_) => List<Digit?>.filled(9, null, growable: false),
    growable: false,
  );
  final digits = List<int>.generate(9, (index) => index + 1);

  List<int>? findEmpty() {
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        if (work[r][c] == null) {
          return [r, c];
        }
      }
    }
    return null;
  }

  bool fill() {
    final spot = findEmpty();
    if (spot == null) {
      return true;
    }
    final rr = spot[0];
    final cc = spot[1];
    final candidates = [...digits]..shuffle(rng);
    for (final val in candidates) {
      if (_isLegal(work, rr, cc, val)) {
        work[rr][cc] = val;
        if (fill()) {
          return true;
        }
        work[rr][cc] = null;
      }
    }
    return false;
  }

  if (!fill()) {
    throw StateError('Unable to generate a solved Sudoku grid');
  }

  return work
      .map((row) => row.map((cell) => cell).toList(growable: false))
      .toList(growable: false);
}

Grid _maskSolution(Grid solution, String difficulty, Random rng) {
  final diff = difficulty.trim().toLowerCase();
  final target = _targetGivens[diff] ?? _targetGivens['easy']!;
  final work = solution.map((row) => row.toList()).toList();
  final coords = <List<int>>[];
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      if (r < 4 || (r == 4 && c <= 4)) {
        coords.add([r, c]);
      }
    }
  }
  coords.shuffle(rng);

  var givens = 81;
  for (final coord in coords) {
    if (givens <= target) {
      break;
    }
    final r = coord[0];
    final c = coord[1];
    final r2 = 8 - r;
    final c2 = 8 - c;
    final removal = (r == r2 && c == c2) ? 1 : 2;
    if (givens - removal < target) {
      continue;
    }
    if (work[r][c] == null && work[r2][c2] == null) {
      continue;
    }
    work[r][c] = null;
    work[r2][c2] = null;
    givens -= removal;
  }
  return work
      .map((row) => row.map((cell) => cell).toList(growable: false))
      .toList(growable: false);
}

bool _isLegal(List<List<Digit?>> grid, int r, int c, Digit digit) {
  for (var cc = 0; cc < 9; cc += 1) {
    if (grid[r][cc] == digit) {
      return false;
    }
  }
  for (var rr = 0; rr < 9; rr += 1) {
    if (grid[rr][c] == digit) {
      return false;
    }
  }
  final br = (r ~/ 3) * 3;
  final bc = (c ~/ 3) * 3;
  for (var rr = br; rr < br + 3; rr += 1) {
    for (var cc = bc; cc < bc + 3; cc += 1) {
      if (grid[rr][cc] == digit) {
        return false;
      }
    }
  }
  return true;
}
