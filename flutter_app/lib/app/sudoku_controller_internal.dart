part of 'sudoku_controller.dart';

void _onCheckSolutionInternal(SudokuController c) {
  if (c._gameOver) {
    return;
  }
  final result = c._solutionCoordinator.check(
    history: c._history,
    initialGrid: c._initialGrid,
    givens: c._givenCoords(),
  );
  c._incorrectCells = result.incorrect;
  c._correctCells = result.correct;
  c._solutionGrid = null;
  c._solutionAddedCells = {};
  c._selected = null;
  c._gameOver = true;
  c._settings.setPuzzleModeLocked(false);
  c._clearCorrectionPromptState(clearRevertedCells: true);
  c._saveGameSession();
  c._render('Check complete');
}

void _onShowSolutionInternal(SudokuController c) {
  if (!c._gameOver) {
    c.onCheckSolution();
  }
  if (!c._gameOver) {
    return;
  }
  final result = c._solutionCoordinator.showSolution(
    history: c._history,
    initialGrid: c._initialGrid,
    givens: c._givenCoords(),
  );
  c._incorrectCells = result.incorrect;
  c._correctCells = result.correct;
  c._solutionGrid = result.solutionGrid;
  c._solutionAddedCells = result.solutionAdded;
  c._selected = null;
  c._settings.setPuzzleModeLocked(false);
  c._clearCorrectionPromptState(clearRevertedCells: true);
  c._saveGameSession();
  c._render('Solution');
}

void _onConfirmCorrectionInternal(SudokuController c) {
  final target = c._correctionState.pendingPromptCoord;
  if (target == null || c._correctionState.tokensLeft <= 0) {
    return;
  }

  final analysis = c._contradictionService.analyze(c._history.present.board);
  if (!analysis.deadCells.contains(target)) {
    c._clearCorrectionPromptState(clearRevertedCells: true);
    c._saveGameSession();
    c._render('No correction needed.');
    return;
  }

  final clearSet = _cellsToClearForDeadCell(c, target);
  if (clearSet.isEmpty) {
    c._clearCorrectionPromptState(clearRevertedCells: true);
    c._saveGameSession();
    c._render('No recoverable correction found.');
    return;
  }

  var nextBoard = c._history.present.board;
  for (final coord in clearSet) {
    nextBoard = ops.clearValue(nextBoard, coord);
  }

  c._history = c._history.push(GameState(board: nextBoard));
  c._lastConflicts = c._contradictionService
      .analyze(c._history.present.board)
      .contradictionCells;
  c._correctionState = c._correctionState.copyWith(
    tokensLeft: c._correctionState.tokensLeft - 1,
    currentMoveId: c._correctionState.currentMoveId + 1,
    revertedCells: clearSet,
    pendingPromptCoord: null,
  );
  c._saveGameSession();
  c._render('Correction used. Cleared ${clearSet.length} tile(s).');
}

void _onDismissCorrectionPromptInternal(SudokuController c) {
  if (c._correctionState.pendingPromptCoord == null) {
    return;
  }
  c._clearCorrectionPromptState(clearRevertedCells: false);
  c._saveGameSession();
  c.notifyListeners();
}

void _applyBoardEditOutcomeInternal(
  SudokuController c,
  BoardEditOutcome outcome,
) {
  if (outcome.statusMessage != null) {
    c._render(outcome.statusMessage!);
    return;
  }
  if (outcome.result == null) {
    return;
  }

  final boardChanged =
      outcome.result!.history.present.board != c._history.present.board;
  c._applyPlayerResult(outcome.result!, boardChanged: boardChanged);
  if (outcome.lockDifficulty) {
    c._settings.setDifficultyLocked(true);
  }
  if (outcome.lockPuzzleMode) {
    c._settings.setPuzzleModeLocked(true);
  }
}

void _applyResultInternal(
  SudokuController c,
  MoveResult res, {
  String? statusOverride,
}) {
  c._history = res.history;
  c._lastConflicts = res.conflicts;
  c._saveGameSession();
  c._render(statusOverride ?? res.message);
}

void _applyPlayerResultInternal(
  SudokuController c,
  MoveResult res, {
  required bool boardChanged,
}) {
  final nextMoveId = boardChanged
      ? c._correctionState.currentMoveId + 1
      : c._correctionState.currentMoveId;
  c._history = res.history;

  final analysis = c._contradictionService.analyze(c._history.present.board);
  c._lastConflicts = analysis.hasContradiction
      ? analysis.contradictionCells
      : res.conflicts;

  var nextCorrection = c._correctionState.copyWith(
    currentMoveId: nextMoveId,
    pendingPromptCoord: null,
    revertedCells: boardChanged ? const {} : c._correctionState.revertedCells,
  );

  if (boardChanged && !analysis.hasContradiction) {
    final checkpoints = nextCorrection.prunedToMoveId(
      c._correctionState.currentMoveId,
    );
    nextCorrection = nextCorrection.copyWith(
      checkpoints: [
        ...checkpoints,
        CorrectionCheckpoint(history: c._history, moveId: nextMoveId),
      ],
    );
  }

  c._correctionState = nextCorrection;
  c._saveGameSession();

  if (analysis.hasContradiction && c._correctionState.tokensLeft == 0) {
    c._render('Contradiction detected. Use Undo to recover.');
    return;
  }
  c._render(res.message);
}

UiState _buildStateInternal(SudokuController c) {
  return c._uiStateMapper.map(
    UiStateMapperInput(
      board: c._history.present.board,
      settings: c._settings.state,
      selected: c._selected,
      conflicts: c._lastConflicts,
      incorrectCells: c._incorrectCells,
      correctCells: c._correctCells,
      solutionAddedCells: c._solutionAddedCells,
      solutionGrid: c._solutionGrid,
      gameOver: c._gameOver,
      revertedCells: c._correctionState.revertedCells,
      correctionsLeft: c._correctionState.tokensLeft,
      canUndo: c._history.canUndo(),
      correctionPromptCoord: c._correctionState.pendingPromptCoord,
      debugScenarioLabel: c._debugScenarioLabel,
    ),
  );
}

Set<Coord> _givenCoordsInternal(SudokuController c) {
  final givens = <Coord>{};
  final board = c._history.present.board;
  for (var r = 0; r < 9; r += 1) {
    for (var col = 0; col < 9; col += 1) {
      if (board.cellAt(r, col).given) {
        givens.add(Coord(r, col));
      }
    }
  }
  return givens;
}

void _saveGameSessionInternal(SudokuController c) {
  c._sessionService.save(
    history: c._history,
    selected: c._selected,
    gameOver: c._gameOver,
    initialGrid: c._initialGrid,
    settings: c._settings.state,
    correctionState: c._correctionState,
    debugScenarioLabel: c._debugScenarioLabel,
  );
}

void _startPuzzleInternal(SudokuController c) {
  final puzzle = puzzles.generatePuzzle(
    c._settings.state.difficulty,
    mode: c._settings.state.puzzleMode,
  );
  final res = c._service.newGameFromGrid(puzzle.grid);
  c._resetBoardFlags();
  c._initialGrid = List<List<Digit?>>.generate(9, (r) {
    return List<Digit?>.generate(
      9,
      (col) => puzzle.grid[r][col],
      growable: false,
    );
  }, growable: false);
  c._applyResult(
    res,
    statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
  );
  c._correctionState = CorrectionState.initial(
    difficulty: puzzle.difficulty,
    history: c._history,
  );
  c._debugScenarioLabel = null;
  c._saveGameSession();
}

void _resetBoardFlagsInternal(SudokuController c) {
  c._selected = null;
  c._lastConflicts = {};
  c._settings.setDifficultyLocked(false);
  c._settings.setPuzzleModeLocked(false);
  c._gameOver = false;
  c._incorrectCells = {};
  c._solutionAddedCells = {};
  c._correctCells = {};
  c._solutionGrid = null;
  c._debugScenarioLabel = null;
  c._clearCorrectionPromptState(clearRevertedCells: true);
}

void _applyRestoredSettingsInternal(
  SudokuController c,
  SettingsState settings,
) {
  c._settings.setDifficultyLocked(false);
  c._settings.setPuzzleModeLocked(false);
  c._settings.setStyleName(settings.styleName);
  c._settings.setContentMode(settings.contentMode);
  c._settings.setAnimalStyle(settings.animalStyle);
  c._settings.setNotesMode(settings.notesMode);
  c._settings.setDifficulty(settings.difficulty);
  c._settings.setPuzzleMode(settings.puzzleMode);
  c._settings.setDifficultyLocked(!settings.canChangeDifficulty);
  c._settings.setPuzzleModeLocked(!settings.canChangePuzzleMode);
}

void _clearCorrectionPromptStateInternal(
  SudokuController c, {
  required bool clearRevertedCells,
}) {
  c._correctionState = c._correctionState.copyWith(
    pendingPromptCoord: null,
    revertedCells: clearRevertedCells
        ? const {}
        : c._correctionState.revertedCells,
  );
}

void _queueCorrectionPromptForSelectionInternal(
  SudokuController c,
  Coord coord,
) {
  final cell = c._history.present.board.cellAtCoord(coord);
  if (cell.value != null || c._correctionState.tokensLeft <= 0) {
    c._correctionState = c._correctionState.copyWith(pendingPromptCoord: null);
    return;
  }
  final analysis = c._contradictionService.analyze(c._history.present.board);
  c._correctionState = c._correctionState.copyWith(
    pendingPromptCoord: analysis.deadCells.contains(coord) ? coord : null,
    revertedCells: const {},
  );
}

Set<Coord> _changedCellsInternal(SudokuController c, Board from, Board to) {
  final changed = <Coord>{};
  for (var r = 0; r < 9; r += 1) {
    for (var col = 0; col < 9; col += 1) {
      final coord = Coord(r, col);
      final before = from.cellAtCoord(coord);
      final after = to.cellAtCoord(coord);
      if (before.value != after.value ||
          before.given != after.given ||
          before.notes.length != after.notes.length ||
          !before.notes.containsAll(after.notes)) {
        changed.add(coord);
      }
    }
  }
  return changed;
}

Set<Coord> _cellsToClearForDeadCell(SudokuController c, Coord target) {
  final board = c._history.present.board;
  final peers = _peerCoords(target);
  final blockersByDigit = <int, List<Coord>>{};
  for (final peer in peers) {
    final value = board.cellAtCoord(peer).value;
    if (value == null) {
      continue;
    }
    blockersByDigit.putIfAbsent(value, () => <Coord>[]).add(peer);
  }

  final recencyRank = _recentValueChangeRank(c._history);
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
