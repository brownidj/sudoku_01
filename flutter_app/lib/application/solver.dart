import 'package:flutter_app/domain/types.dart';

Grid? solveGrid(Grid grid) {
  final work = grid.map((row) => row.toList()).toList();

  bool isLegal(int r, int c, int val) {
    for (var cc = 0; cc < 9; cc += 1) {
      if (work[r][cc] == val) {
        return false;
      }
    }
    for (var rr = 0; rr < 9; rr += 1) {
      if (work[rr][c] == val) {
        return false;
      }
    }
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (var rr = br; rr < br + 3; rr += 1) {
      for (var cc = bc; cc < bc + 3; cc += 1) {
        if (work[rr][cc] == val) {
          return false;
        }
      }
    }
    return true;
  }

  List<int> candidatesFor(int r, int c) {
    final candidates = <int>[];
    for (var d = 1; d <= 9; d += 1) {
      if (isLegal(r, c, d)) {
        candidates.add(d);
      }
    }
    return candidates;
  }

  bool solve() {
    int? bestR;
    int? bestC;
    List<int>? bestCandidates;
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        if (work[r][c] != null) {
          continue;
        }
        final candidates = candidatesFor(r, c);
        if (candidates.isEmpty) {
          return false;
        }
        if (bestCandidates == null || candidates.length < bestCandidates.length) {
          bestCandidates = candidates;
          bestR = r;
          bestC = c;
          if (bestCandidates.length == 1) {
            break;
          }
        }
      }
      if (bestCandidates != null && bestCandidates.length == 1) {
        break;
      }
    }
    if (bestCandidates == null || bestR == null || bestC == null) {
      return true;
    }
    for (final val in bestCandidates) {
      work[bestR][bestC] = val;
      if (solve()) {
        return true;
      }
      work[bestR][bestC] = null;
    }
    return false;
  }

  if (!solve()) {
    return null;
  }
  return work.map((row) => row.toList(growable: false)).toList(growable: false);
}
