part of 'sudoku_controller.dart';

void _onCheckSolutionInternal(SudokuController c) {
  if (c._runtime.gameOver) {
    return;
  }
  final result = c._solutionCoordinator.check(
    history: c._runtime.history,
    initialGrid: c._runtime.initialGrid,
    givens: c._givenCoords(),
  );
  c._runtime
    ..incorrectCells = result.incorrect
    ..correctCells = result.correct
    ..solutionGrid = null
    ..solutionAddedCells = {}
    ..selected = null
    ..gameOver = true;
  c._settings.setPuzzleModeLocked(false);
  c._clearCorrectionPromptState(clearRevertedCells: true);
  c._saveGameSession();
  c._render('Check complete');
}

void _onShowSolutionInternal(SudokuController c) {
  if (!c._runtime.gameOver) {
    c.onCheckSolution();
  }
  if (!c._runtime.gameOver) {
    return;
  }
  final result = c._solutionCoordinator.showSolution(
    history: c._runtime.history,
    initialGrid: c._runtime.initialGrid,
    givens: c._givenCoords(),
  );
  c._runtime
    ..incorrectCells = result.incorrect
    ..correctCells = result.correct
    ..solutionGrid = result.solutionGrid
    ..solutionAddedCells = result.solutionAdded
    ..selected = null;
  c._settings.setPuzzleModeLocked(false);
  c._clearCorrectionPromptState(clearRevertedCells: true);
  c._saveGameSession();
  c._render('Solution');
}

void _onConfirmCorrectionInternal(SudokuController c) {
  if (c._runtime.correctionState.pendingPromptCoord == null ||
      c._runtime.correctionState.tokensLeft <= 0) {
    return;
  }
  final result = c._correctionRecoveryService.confirmCorrection(
    history: c._runtime.history,
    correctionState: c._runtime.correctionState,
  );
  c._runtime
    ..history = result.history
    ..lastConflicts = result.conflicts
    ..correctionState = result.correctionState;
  c._saveGameSession();
  c._render(result.status);
}

void _onDismissCorrectionPromptInternal(SudokuController c) {
  if (c._runtime.correctionState.pendingPromptCoord == null) {
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
      outcome.result!.history.present.board != c._runtime.history.present.board;
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
  c._runtime
    ..history = res.history
    ..lastConflicts = res.conflicts;
  c._saveGameSession();
  c._render(statusOverride ?? res.message);
}

void _applyPlayerResultInternal(
  SudokuController c,
  MoveResult res, {
  required bool boardChanged,
}) {
  final nextMoveId = boardChanged
      ? c._runtime.correctionState.currentMoveId + 1
      : c._runtime.correctionState.currentMoveId;
  c._runtime.history = res.history;

  final analysis = c._contradictionService.analyze(
    c._runtime.history.present.board,
  );
  c._runtime.lastConflicts = analysis.hasContradiction
      ? analysis.contradictionCells
      : res.conflicts;

  var nextCorrection = c._runtime.correctionState.copyWith(
    currentMoveId: nextMoveId,
    pendingPromptCoord: null,
    revertedCells: boardChanged
        ? const {}
        : c._runtime.correctionState.revertedCells,
  );

  if (boardChanged && !analysis.hasContradiction) {
    final checkpoints = nextCorrection.prunedToMoveId(
      c._runtime.correctionState.currentMoveId,
    );
    nextCorrection = nextCorrection.copyWith(
      checkpoints: [
        ...checkpoints,
        CorrectionCheckpoint(history: c._runtime.history, moveId: nextMoveId),
      ],
    );
  }

  c._runtime.correctionState = nextCorrection;
  c._saveGameSession();

  if (analysis.hasContradiction && c._runtime.correctionState.tokensLeft == 0) {
    c._render('Contradiction detected. Use Undo to recover.');
    return;
  }
  c._render(res.message);
}

UiState _buildStateInternal(SudokuController c) {
  return c._uiStateMapper.map(
    UiStateMapperInput(
      board: c._runtime.history.present.board,
      settings: c._settings.state,
      selected: c._runtime.selected,
      conflicts: c._runtime.lastConflicts,
      incorrectCells: c._runtime.incorrectCells,
      correctCells: c._runtime.correctCells,
      solutionAddedCells: c._runtime.solutionAddedCells,
      solutionGrid: c._runtime.solutionGrid,
      gameOver: c._runtime.gameOver,
      revertedCells: c._runtime.correctionState.revertedCells,
      correctionsLeft: c._runtime.correctionState.tokensLeft,
      canUndo: c._runtime.history.canUndo(),
      correctionPromptCoord: c._runtime.correctionState.pendingPromptCoord,
      debugScenarioLabel: c._runtime.debugScenarioLabel,
    ),
  );
}

Set<Coord> _givenCoordsInternal(SudokuController c) {
  final givens = <Coord>{};
  final board = c._runtime.history.present.board;
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
    history: c._runtime.history,
    selected: c._runtime.selected,
    gameOver: c._runtime.gameOver,
    initialGrid: c._runtime.initialGrid,
    settings: c._settings.state,
    correctionState: c._runtime.correctionState,
    debugScenarioLabel: c._runtime.debugScenarioLabel,
  );
}

void _startPuzzleInternal(SudokuController c) {
  final puzzle = puzzles.generatePuzzle(
    c._settings.state.difficulty,
    mode: c._settings.state.puzzleMode,
  );
  final res = c._service.newGameFromGrid(puzzle.grid);
  c._resetBoardFlags();
  c._runtime.initialGrid = List<List<Digit?>>.generate(9, (r) {
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
  c._runtime
    ..correctionState = CorrectionState.initial(
      difficulty: puzzle.difficulty,
      history: c._runtime.history,
    )
    ..debugScenarioLabel = null;
  c._saveGameSession();
}

void _resetBoardFlagsInternal(SudokuController c) {
  c._runtime
    ..selected = null
    ..lastConflicts = {}
    ..gameOver = false
    ..incorrectCells = {}
    ..solutionAddedCells = {}
    ..correctCells = {}
    ..solutionGrid = null
    ..debugScenarioLabel = null;
  c._settings.setDifficultyLocked(false);
  c._settings.setPuzzleModeLocked(false);
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
  c._runtime.correctionState = c._runtime.correctionState.copyWith(
    pendingPromptCoord: null,
    revertedCells: clearRevertedCells
        ? const {}
        : c._runtime.correctionState.revertedCells,
  );
}

void _queueCorrectionPromptForSelectionInternal(
  SudokuController c,
  Coord coord,
) {
  c._runtime.correctionState = c._correctionRecoveryService
      .queuePromptForSelection(
        history: c._runtime.history,
        correctionState: c._runtime.correctionState,
        coord: coord,
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
