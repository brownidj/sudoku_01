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
  final promptMoveId = c._correctionState.pendingPromptMoveId;
  if (promptMoveId == null || c._correctionState.tokensLeft <= 0) {
    return;
  }
  final checkpoint = c._correctionState.latestCheckpointBefore(promptMoveId);
  if (checkpoint == null) {
    c._clearCorrectionPromptState(clearRevertedCells: true);
    c._saveGameSession();
    c.notifyListeners();
    return;
  }

  final revertedCells = c._changedCells(
    c._history.present.board,
    checkpoint.board,
  );
  c._history = checkpoint.history;
  c._lastConflicts = {};
  c._correctionState = c._correctionState.copyWith(
    tokensLeft: c._correctionState.tokensLeft - 1,
    currentMoveId: checkpoint.moveId,
    checkpoints: c._correctionState.prunedToMoveId(checkpoint.moveId),
    revertedCells: revertedCells,
    pendingPromptMoveId: null,
  );
  c._saveGameSession();
  c._render('Correction used.');
}

void _onDismissCorrectionPromptInternal(SudokuController c) {
  if (c._correctionState.pendingPromptMoveId == null) {
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
    pendingPromptMoveId:
        analysis.hasContradiction &&
            boardChanged &&
            c._correctionState.tokensLeft > 0
        ? nextMoveId
        : null,
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
      correctionPromptMoveId: c._correctionState.pendingPromptMoveId,
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
    pendingPromptMoveId: null,
    revertedCells: clearRevertedCells
        ? const {}
        : c._correctionState.revertedCells,
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
