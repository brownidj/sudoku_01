part of 'sudoku_screen.dart';

extension SudokuScreenHandlers on _SudokuScreenState {
  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final controller = widget.controller;
    final state = controller.state;
    _ensureAnimalAssetsRequested(state.contentMode);
    _services.onControllerChanged(
      context: context,
      state: state,
      isMounted: () => mounted,
      showCorrectionPrompt: () async {
        await _services.showCorrectionPrompt(
          context: context,
          isMounted: () => mounted,
          onConfirmCorrection: controller.onConfirmCorrection,
          onCorrectionConfirmed:
              _services.candidatePanelCoordinator.onCorrectionConfirmed,
          onDismissCorrectionPrompt: controller.onDismissCorrectionPrompt,
          currentState: () => controller.state,
        );
      },
    );
    _startInstructionOverlayService.onStateChanged(
      context: context,
      state: state,
      isMounted: () => mounted,
    );
  }

  void _ensureAnimalAssetsRequested(String contentMode) {
    if (contentMode == 'numbers' || _animalLoad != null) {
      return;
    }
    _animalLoad = _loadAnimalImages();
  }

  Future<void> _loadAnimalImages() async {
    try {
      final bundle = await widget.animalAssetService.load();
      _animalImages
        ..clear()
        ..addAll(bundle.animalImages);
      _noteImages
        ..clear()
        ..addAll(bundle.noteImages);
      if (mounted) {
        setState(() {});
      }
    } on Exception catch (error) {
      AppDebug.log('Failed to load visual assets: $error');
      _animalLoad = null;
    }
  }

  void _onNewGamePressed() {
    unawaited(
      _flowActions.requestNewGame(
        context: context,
        isMounted: () => mounted,
        controller: widget.controller,
        onConfirmed: () {
          unawaited(_services.backgroundMusicService.pickNewRandomTrack());
        },
      ),
    );
  }

  void _onVersionTapped() {
    final result = _services.interactionController.onVersionTapped(
      appDebugEnabled: AppDebug.enabled,
    );
    if (result.toggleDebugTools) {
      setState(() {
        _debugToolsEnabled = !_debugToolsEnabled;
      });
    }
  }

  void _onMusicControlTapped() {
    final now = DateTime.now();
    final lastTap = _lastMusicControlTapAt;
    final isDoubleTap =
        lastTap != null &&
        now.difference(lastTap) <= const Duration(milliseconds: 320);
    _lastMusicControlTapAt = now;

    if (isDoubleTap) {
      _pendingMusicSingleTapTimer?.cancel();
      _pendingMusicSingleTapTimer = null;
      _setBackgroundMusicEnabledFromAppBar(true);
      return;
    }

    _pendingMusicSingleTapTimer?.cancel();
    _pendingMusicSingleTapTimer = Timer(const Duration(milliseconds: 340), () {
      _setBackgroundMusicEnabledFromAppBar(false);
    });
  }

  void _onPreviousTrackTapped() {
    if (!_backgroundMusicEnabled) {
      return;
    }
    unawaited(_services.backgroundMusicService.playPreviousTrack());
  }

  void _onNextTrackTapped() {
    if (!_backgroundMusicEnabled) {
      return;
    }
    unawaited(_services.backgroundMusicService.playNextTrack());
  }

  void _setBackgroundMusicEnabledFromAppBar(bool enabled) {
    if (enabled && !_audioEnabled) {
      setState(() {
        _audioEnabled = true;
        _backgroundMusicEnabled = true;
      });
      _services.onAudioEnabledChanged(true);
      _services.onBackgroundMusicEnabledChanged(true);
      unawaited(_persistAudioPreferences());
      return;
    }
    _onBackgroundMusicEnabledChanged(enabled);
  }

  void _onAudioEnabledChanged(bool enabled) {
    if (_audioEnabled == enabled) {
      return;
    }
    final nextBackgroundMusic = enabled ? _backgroundMusicEnabled : false;
    setState(() {
      _audioEnabled = enabled;
      _backgroundMusicEnabled = nextBackgroundMusic;
    });
    _services.onAudioEnabledChanged(enabled);
    _services.onBackgroundMusicEnabledChanged(nextBackgroundMusic);
    unawaited(_persistAudioPreferences());
  }

  void _onBackgroundMusicEnabledChanged(bool enabled) {
    if (!_audioEnabled) {
      return;
    }
    if (_backgroundMusicEnabled == enabled) {
      return;
    }
    setState(() {
      _backgroundMusicEnabled = enabled;
    });
    _services.onBackgroundMusicEnabledChanged(enabled);
    unawaited(_persistAudioPreferences());
  }

  void _onAudioVolumeChanged(double volume) {
    if (_audioVolume == volume) {
      return;
    }
    setState(() {
      _audioVolume = volume;
    });
    _services.onAudioVolumeChanged(volume);
    unawaited(_persistAudioPreferences());
  }

  Future<void> _loadAudioPreferences() async {
    final store = PreferencesStore();
    final storedAudio = await store.loadAudioEnabled();
    final storedBackground = await store.loadBackgroundMusicEnabled();
    final storedVolume = await store.loadAudioVolume();
    if (!mounted) {
      return;
    }
    final nextAudio = storedAudio;
    final nextBackground = nextAudio ? storedBackground : false;
    setState(() {
      _audioEnabled = nextAudio;
      _backgroundMusicEnabled = nextBackground;
      _audioVolume = storedVolume;
    });
    _services.onBackgroundMusicEnabledChanged(nextBackground);
    _services.onAudioEnabledChanged(nextAudio);
    _services.onAudioVolumeChanged(storedVolume);
  }

  Future<void> _persistAudioPreferences() async {
    final store = PreferencesStore();
    await store.saveAudioEnabled(_audioEnabled);
    await store.saveBackgroundMusicEnabled(_backgroundMusicEnabled);
    await store.saveAudioVolume(_audioVolume);
  }
}
