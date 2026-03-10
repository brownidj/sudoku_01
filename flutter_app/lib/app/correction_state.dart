import 'dart:collection';

import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

int correctionsForDifficulty(String difficulty) {
  switch (difficulty) {
    case 'hard':
      return 1;
    case 'medium':
      return 3;
    default:
      return 5;
  }
}

class CorrectionCheckpoint {
  final History history;
  final int moveId;

  const CorrectionCheckpoint({required this.history, required this.moveId});

  Board get board => history.present.board;
}

class CorrectionState {
  final int tokensLeft;
  final int currentMoveId;
  final List<CorrectionCheckpoint> checkpoints;
  final Set<Coord> revertedCells;
  final Coord? pendingPromptCoord;

  CorrectionState({
    required this.tokensLeft,
    required this.currentMoveId,
    required List<CorrectionCheckpoint> checkpoints,
    required Set<Coord> revertedCells,
    required this.pendingPromptCoord,
  }) : checkpoints = List.unmodifiable(checkpoints),
       revertedCells = Set.unmodifiable(revertedCells);

  factory CorrectionState.initial({
    required String difficulty,
    required History history,
  }) {
    return CorrectionState(
      tokensLeft: correctionsForDifficulty(difficulty),
      currentMoveId: 0,
      checkpoints: [CorrectionCheckpoint(history: history, moveId: 0)],
      revertedCells: const {},
      pendingPromptCoord: null,
    );
  }

  CorrectionState copyWith({
    int? tokensLeft,
    int? currentMoveId,
    List<CorrectionCheckpoint>? checkpoints,
    Set<Coord>? revertedCells,
    Object? pendingPromptCoord = _sentinel,
  }) {
    return CorrectionState(
      tokensLeft: tokensLeft ?? this.tokensLeft,
      currentMoveId: currentMoveId ?? this.currentMoveId,
      checkpoints: checkpoints ?? this.checkpoints,
      revertedCells: revertedCells ?? this.revertedCells,
      pendingPromptCoord: identical(pendingPromptCoord, _sentinel)
          ? this.pendingPromptCoord
          : pendingPromptCoord as Coord?,
    );
  }

  CorrectionCheckpoint? latestCheckpointBefore(int moveId) {
    for (var i = checkpoints.length - 1; i >= 0; i -= 1) {
      final checkpoint = checkpoints[i];
      if (checkpoint.moveId < moveId) {
        return checkpoint;
      }
    }
    return checkpoints.isEmpty ? null : checkpoints.first;
  }

  List<CorrectionCheckpoint> prunedToMoveId(int moveId) {
    return checkpoints
        .where((checkpoint) => checkpoint.moveId <= moveId)
        .toList(growable: false);
  }

  static const Object _sentinel = Object();
}
