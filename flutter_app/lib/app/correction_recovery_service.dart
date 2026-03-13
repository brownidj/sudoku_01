import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/ops.dart' as ops;
import 'package:flutter_app/domain/types.dart';

class CorrectionRecoveryResult {
  final History history;
  final CorrectionState correctionState;
  final Set<Coord> conflicts;
  final String status;

  const CorrectionRecoveryResult({
    required this.history,
    required this.correctionState,
    required this.conflicts,
    required this.status,
  });
}

class CorrectionRecoveryService {
  final ContradictionService contradictionService;

  const CorrectionRecoveryService({
    this.contradictionService = const ContradictionService(),
  });

  CorrectionState queuePromptForSelection({
    required History history,
    required CorrectionState correctionState,
    required Coord coord,
  }) {
    final cell = history.present.board.cellAtCoord(coord);
    if (cell.value != null || correctionState.tokensLeft <= 0) {
      return correctionState.copyWith(pendingPromptCoord: null);
    }
    final analysis = contradictionService.analyze(history.present.board);
    return correctionState.copyWith(
      pendingPromptCoord: analysis.deadCells.contains(coord) ? coord : null,
      revertedCells: const {},
    );
  }

  CorrectionRecoveryResult confirmCorrection({
    required History history,
    required CorrectionState correctionState,
  }) {
    final target = correctionState.pendingPromptCoord;
    if (target == null || correctionState.tokensLeft <= 0) {
      return CorrectionRecoveryResult(
        history: history,
        correctionState: correctionState,
        conflicts: contradictionService
            .analyze(history.present.board)
            .contradictionCells,
        status: '',
      );
    }

    final analysis = contradictionService.analyze(history.present.board);
    if (!analysis.deadCells.contains(target)) {
      return CorrectionRecoveryResult(
        history: history,
        correctionState: correctionState.copyWith(
          pendingPromptCoord: null,
          revertedCells: const {},
        ),
        conflicts: analysis.contradictionCells,
        status: 'No correction needed.',
      );
    }

    final clearSet = _cellsToClearForDeadCell(history, target);
    if (clearSet.isEmpty) {
      return CorrectionRecoveryResult(
        history: history,
        correctionState: correctionState.copyWith(
          pendingPromptCoord: null,
          revertedCells: const {},
        ),
        conflicts: analysis.contradictionCells,
        status: 'No recoverable correction found.',
      );
    }

    var nextBoard = history.present.board;
    for (final coord in clearSet) {
      nextBoard = ops.clearValue(nextBoard, coord);
    }

    final nextHistory = history.push(GameState(board: nextBoard));
    final nextAnalysis = contradictionService.analyze(
      nextHistory.present.board,
    );
    return CorrectionRecoveryResult(
      history: nextHistory,
      correctionState: correctionState.copyWith(
        tokensLeft: correctionState.tokensLeft - 1,
        currentMoveId: correctionState.currentMoveId + 1,
        revertedCells: clearSet,
        pendingPromptCoord: null,
      ),
      conflicts: nextAnalysis.contradictionCells,
      status: 'Correction used. Cleared ${clearSet.length} tile(s).',
    );
  }

  Set<Coord> _cellsToClearForDeadCell(History history, Coord target) {
    final board = history.present.board;
    final peers = _peerCoords(target);
    final blockersByDigit = <int, List<Coord>>{};
    for (final peer in peers) {
      final value = board.cellAtCoord(peer).value;
      if (value == null) {
        continue;
      }
      blockersByDigit.putIfAbsent(value, () => <Coord>[]).add(peer);
    }

    final recencyRank = _recentValueChangeRank(history);
    List<Coord>? best;
    var bestScore = 1 << 30;
    for (var digit = 1; digit <= 9; digit += 1) {
      final blockers = blockersByDigit[digit];
      if (blockers == null || blockers.isEmpty) {
        continue;
      }
      if (blockers.any((coord) => board.cellAtCoord(coord).given)) {
        continue;
      }
      final score = blockers.fold<int>(
        0,
        (sum, coord) => sum + (recencyRank[coord] ?? 1000),
      );
      if (best == null ||
          blockers.length < best.length ||
          (blockers.length == best.length && score < bestScore)) {
        best = blockers;
        bestScore = score;
      }
    }
    if (best != null) {
      return best.toSet();
    }

    Coord? fallback;
    var fallbackScore = 1000;
    for (final peer in peers) {
      final peerCell = board.cellAtCoord(peer);
      if (peerCell.value == null || peerCell.given) {
        continue;
      }
      final score = recencyRank[peer] ?? 1000;
      if (fallback == null || score < fallbackScore) {
        fallback = peer;
        fallbackScore = score;
      }
    }
    return fallback == null ? <Coord>{} : <Coord>{fallback};
  }

  Set<Coord> _peerCoords(Coord coord) {
    final peers = <Coord>{};
    for (var c = 0; c < 9; c += 1) {
      if (c != coord.col) {
        peers.add(Coord(coord.row, c));
      }
    }
    for (var r = 0; r < 9; r += 1) {
      if (r != coord.row) {
        peers.add(Coord(r, coord.col));
      }
    }
    final br = (coord.row ~/ 3) * 3;
    final bc = (coord.col ~/ 3) * 3;
    for (var r = br; r < br + 3; r += 1) {
      for (var c = bc; c < bc + 3; c += 1) {
        if (r == coord.row && c == coord.col) {
          continue;
        }
        peers.add(Coord(r, c));
      }
    }
    return peers;
  }

  Map<Coord, int> _recentValueChangeRank(History history) {
    final states = <GameState>[...history.past, history.present];
    final rank = <Coord, int>{};
    var index = 0;
    for (var i = states.length - 1; i > 0; i -= 1) {
      final coord = _valueChangeCoord(states[i - 1].board, states[i].board);
      if (coord == null || rank.containsKey(coord)) {
        continue;
      }
      rank[coord] = index;
      index += 1;
    }
    return rank;
  }

  Coord? _valueChangeCoord(Board before, Board after) {
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        if (before.cellAtCoord(coord).value != after.cellAtCoord(coord).value) {
          return coord;
        }
      }
    }
    return null;
  }
}
