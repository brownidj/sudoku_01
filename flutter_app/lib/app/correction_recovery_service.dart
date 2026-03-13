import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/application/solver.dart';
import 'package:flutter_app/domain/ops.dart' as ops;
import 'package:flutter_app/domain/types.dart';

class CorrectionRecoveryResult {
  final History history;
  final CorrectionState correctionState;
  final Set<Coord> conflicts;
  final String status;
  final int correctedTiles;

  const CorrectionRecoveryResult({
    required this.history,
    required this.correctionState,
    required this.conflicts,
    required this.status,
    required this.correctedTiles,
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
    required Grid? initialGrid,
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
        correctedTiles: 0,
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
        correctedTiles: 0,
      );
    }

    final clearSet = _incorrectCellsToClear(
      history: history,
      initialGrid: initialGrid,
    );
    if (clearSet.isEmpty) {
      return CorrectionRecoveryResult(
        history: history,
        correctionState: correctionState.copyWith(
          pendingPromptCoord: null,
          revertedCells: const {},
        ),
        conflicts: analysis.contradictionCells,
        status: 'No recoverable correction found.',
        correctedTiles: 0,
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
      correctedTiles: clearSet.length,
    );
  }

  Set<Coord> _incorrectCellsToClear({
    required History history,
    required Grid? initialGrid,
  }) {
    final solvedGrid = solveGrid(_baseGridForCorrection(history, initialGrid));
    if (solvedGrid == null) {
      return {};
    }
    final board = history.present.board;
    final changed = <Coord>{};
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        final cell = board.cellAtCoord(coord);
        if (cell.given || cell.value == null) {
          continue;
        }
        final solvedValue = solvedGrid[r][c];
        if (solvedValue != null && cell.value != solvedValue) {
          changed.add(coord);
        }
      }
    }
    return changed;
  }

  Grid _baseGridForCorrection(History history, Grid? initialGrid) {
    if (initialGrid != null) {
      return List<List<Digit?>>.generate(9, (r) {
        return List<Digit?>.generate(
          9,
          (c) => initialGrid[r][c],
          growable: false,
        );
      }, growable: false);
    }

    final board = history.present.board;
    return List<List<Digit?>>.generate(9, (r) {
      return List<Digit?>.generate(9, (c) {
        final cell = board.cellAt(r, c);
        return cell.given ? cell.value : null;
      }, growable: false);
    }, growable: false);
  }
}
