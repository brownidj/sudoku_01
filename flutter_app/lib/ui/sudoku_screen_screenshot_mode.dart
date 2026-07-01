part of 'sudoku_screen.dart';

extension _SudokuScreenScreenshotMode on _SudokuScreenState {
  Future<void> _applyScreenshotSceneIfNeeded() async {
    if (!ScreenshotMode.enabled ||
        ScreenshotMode.isHome ||
        _screenshotSceneApplied) {
      return;
    }
    _screenshotSceneApplied = true;
    await widget.controller.ready;
    if (!mounted) {
      return;
    }
    _startInstructionOverlayServiceForScreenshot();
    _configureAudioForCapture();

    switch (ScreenshotMode.scene) {
      case 'drawer_open':
        await _prepareBaseScene(theme: 'animals', premium: false);
        _scaffoldKey.currentState?.openDrawer();
        await _waitForCondition(
          () => _scaffoldKey.currentState?.isDrawerOpen ?? false,
        );
        break;
      case 'new_game':
        await _prepareBaseScene(
          theme: ScreenshotMode.theme,
          premium: ScreenshotMode.requiresPremiumTheme,
        );
        await _selectEmptyTileForScreenshot();
        break;
      case 'partial_progress':
        await _prepareBaseScene(
          theme: ScreenshotMode.theme,
          premium: ScreenshotMode.requiresPremiumTheme,
        );
        await _applyDeterministicSolutionMovesUntilRemainingEmpties(2);
        break;
      case 'celebration':
        await _prepareBaseScene(theme: 'animals', premium: false);
        await _applyDeterministicSolutionMovesUntilRemainingEmpties(0);
        await _waitForCondition(
          () =>
              widget.controller.state.puzzleSolved &&
              _services.victoryOverlayService.state.value.visible,
        );
        break;
      case 'video_finish_celebration':
        await _prepareVideoFinishCelebrationScene();
        return;
      default:
        throw StateError('Unhandled screenshot scene: ${ScreenshotMode.scene}');
    }

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    ScreenshotMode.reportReady();
  }

  Future<void> _prepareVideoFinishCelebrationScene() async {
    await _prepareBaseScene(
      theme: ScreenshotMode.theme,
      premium: ScreenshotMode.requiresPremiumTheme,
    );
    await _applyDeterministicSolutionMovesUntilRemainingEmpties(5);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    ScreenshotMode.reportReady();
    await _playFinishAndCelebrationVideoSequence();
    if (!mounted) {
      return;
    }
    ScreenshotMode.reportDone();
  }

  void _startInstructionOverlayServiceForScreenshot() {
    // No-op marker so screenshot handling remains explicit at the call site.
  }

  void _configureAudioForCapture() {
    if (ScreenshotMode.captureAudio) {
      _updateScreenState(() {
        _audioEnabled = true;
        _backgroundMusicEnabled = true;
        _audioVolume = 0.4;
      });
      _services.onAudioVolumeChanged(0.4);
      _services.onAudioEnabledChanged(true);
      _services.onBackgroundMusicEnabledChanged(true);
      return;
    }

    _updateScreenState(() {
      _audioEnabled = false;
      _backgroundMusicEnabled = false;
      _audioVolume = 0.0;
    });
    _services.onAudioVolumeChanged(0.0);
    _services.onAudioEnabledChanged(false);
    _services.onBackgroundMusicEnabledChanged(false);
  }

  Future<void> _prepareBaseScene({
    required String theme,
    required bool premium,
  }) async {
    widget.controller.onSetEntitlement(
      premium ? Entitlement.premium : Entitlement.free,
    );
    if (widget.controller.state.contentMode != theme) {
      widget.controller.onContentModeChanged(theme);
      await WidgetsBinding.instance.endOfFrame;
    }
    widget.controller.onNewGame();
    _ensureAnimalAssetsRequested(theme);
    if (_animalLoad != null) {
      await _animalLoad;
    }
    await _waitForCondition(() {
      final state = widget.controller.state;
      return state.contentMode == theme &&
          !state.gameOver &&
          !state.puzzleSolved;
    });
  }

  Future<void> _applyDeterministicSolutionMoves(int moveCount) async {
    final solution = solveGrid(_currentGrid());
    if (solution == null) {
      throw StateError('Current screenshot puzzle has no solution.');
    }
    for (var applied = 0; applied < moveCount; applied += 1) {
      final coord = _selectNextDeterministicMove(solution);
      if (coord == null) {
        throw StateError('Unable to apply $moveCount deterministic moves.');
      }
      final digit = solution[coord.row][coord.col];
      if (digit == null) {
        throw StateError('Solution digit missing for $coord.');
      }
      widget.controller.onCellTapped(coord);
      widget.controller.onPlaceDigit(digit);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  Future<void> _applyDeterministicSolutionMovesUntilRemainingEmpties(
    int remainingEmptyCount,
  ) async {
    final emptyCount = _emptyCellCount();
    if (remainingEmptyCount < 0 || remainingEmptyCount > emptyCount) {
      throw StateError(
        'Unsupported remaining empty count: $remainingEmptyCount for $emptyCount empty cells.',
      );
    }
    await _applyDeterministicSolutionMoves(emptyCount - remainingEmptyCount);
  }

  Future<void> _playFinishAndCelebrationVideoSequence() async {
    final solution = solveGrid(_currentGrid());
    if (solution == null) {
      throw StateError('Current screenshot puzzle has no solution.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));

    while (_emptyCellCount() > 0) {
      final coord = _selectNextDeterministicMove(solution);
      if (coord == null) {
        throw StateError('Unable to determine next video move.');
      }
      final digit = solution[coord.row][coord.col];
      if (digit == null) {
        throw StateError('Solution digit missing for $coord.');
      }
      widget.controller.onCellTapped(coord);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      widget.controller.onPlaceDigit(digit);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }

    await _waitForCondition(
      () =>
          widget.controller.state.puzzleSolved &&
          _services.victoryOverlayService.state.value.visible,
      timeout: const Duration(seconds: 8),
    );
    final celebrationAudioAsset =
        SudokuVictoryAudioService.audioAssetForVictoryMascot(
          _services.victoryOverlayService.state.value.assetPath,
        );
    if (celebrationAudioAsset != null) {
      ScreenshotMode.reportCelebrationAudioAsset(celebrationAudioAsset);
    }
    await _waitForCondition(
      () => !_services.victoryOverlayService.state.value.visible,
      timeout: const Duration(seconds: 12),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  Future<void> _selectEmptyTileForScreenshot() async {
    final coord = _selectScreenshotCandidateCell();
    if (coord == null) {
      throw StateError('Unable to find an empty screenshot tile to select.');
    }
    await _services.interactionController.onCellTapped(
      state: widget.controller.state,
      coord: coord,
      animalLoad: _animalLoad,
    );
    await _waitForCondition(() {
      return widget.controller.state.selected == coord &&
          _services.candidatePanelCoordinator.visible &&
          _services.candidatePanelCoordinator.candidateCoord == coord &&
          _services.candidatePanelCoordinator.candidateDigits.isNotEmpty;
    });
  }
}
