part of 'sudoku_screen.dart';

extension _SudokuScreenHandlers on _SudokuScreenState {
  Future<void> _refreshMarineTheme() async {
    try {
      final theme = await MarineGameTheme.load();
      final images = theme == null
          ? <int, ui.Image>{}
          : await MarineGameTheme.decode(theme);
      if (!mounted) {
        for (final image in images.values) {
          image.dispose();
        }
        return;
      }
      _updateScreenState(() {
        _ownedMarineImages.addAll(images.values);
        _marineChecked = true;
        MarineGameTheme.definition = theme;
        _marineAvailable = theme != null;
        _animalImages['marine'] = images;
        _noteImages['marine'] = {
          for (final size in [16, 20, 24, 32]) size: images,
        };
      });
    } catch (error) {
      AppDebug.log('Marine Life is unavailable: $error');
      if (!mounted) return;
      _updateScreenState(() {
        _marineChecked = true;
        MarineGameTheme.definition = null;
        _marineAvailable = false;
        _animalImages.remove('marine');
        _noteImages.remove('marine');
      });
    }
    if (mounted &&
        !_marineAvailable &&
        widget.controller.state.contentMode == 'marine') {
      widget.controller.onContentModeChanged('animals');
    }
  }

  bool get _isBackgroundMusicTheme {
    return _premiumPolicy.isBackgroundMusicThemeMode(
      widget.controller.state.contentMode,
    );
  }

  bool get _effectiveBackgroundMusicEnabled =>
      _audioEnabled && _backgroundMusicEnabled && _isBackgroundMusicTheme;

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final controller = widget.controller;
    final state = controller.state;
    if (_marineChecked && !_marineAvailable && state.contentMode == 'marine') {
      controller.onContentModeChanged('animals');
      return;
    }
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
    if (!ScreenshotMode.enabled) {
      _startInstructionOverlayService.onStateChanged(
        context: context,
        state: state,
        isMounted: () => mounted,
      );
    }
    _services.onBackgroundMusicEnabledChanged(_effectiveBackgroundMusicEnabled);
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
      _animalImages..addAll(bundle.animalImages);
      _noteImages..addAll(bundle.noteImages);
      _updateScreenState(() {});
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
      _updateScreenState(() {
        _debugToolsEnabled = !_debugToolsEnabled;
      });
    }
  }

  void _onMusicControlSingleTap() {
    if (!_isBackgroundMusicTheme) {
      return;
    }
    _setBackgroundMusicEnabledFromAppBar(false);
  }

  void _onMusicControlDoubleTap() {
    if (!_isBackgroundMusicTheme) {
      return;
    }
    _setBackgroundMusicEnabledFromAppBar(true);
  }

  void _onPreviousTrackTapped() {
    if (!_effectiveBackgroundMusicEnabled) {
      return;
    }
    unawaited(_services.backgroundMusicService.playPreviousTrack());
  }

  void _onNextTrackTapped() {
    if (!_effectiveBackgroundMusicEnabled) {
      return;
    }
    unawaited(_services.backgroundMusicService.playNextTrack());
  }

  void _setBackgroundMusicEnabledFromAppBar(bool enabled) {
    if (enabled && !_audioEnabled) {
      _updateScreenState(() {
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
    _updateScreenState(() {
      _audioEnabled = enabled;
      _backgroundMusicEnabled = nextBackgroundMusic;
    });
    _services.onAudioEnabledChanged(enabled);
    _services.onBackgroundMusicEnabledChanged(_effectiveBackgroundMusicEnabled);
    unawaited(_persistAudioPreferences());
  }

  void _onBackgroundMusicEnabledChanged(bool enabled) {
    if (!_audioEnabled) {
      return;
    }
    if (_backgroundMusicEnabled == enabled) {
      return;
    }
    _updateScreenState(() {
      _backgroundMusicEnabled = enabled;
    });
    _services.onBackgroundMusicEnabledChanged(_effectiveBackgroundMusicEnabled);
    unawaited(_persistAudioPreferences());
  }

  void _onAudioVolumeChanged(double volume) {
    if (_audioVolume == volume) {
      return;
    }
    _updateScreenState(() {
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
    _updateScreenState(() {
      _audioEnabled = nextAudio;
      _backgroundMusicEnabled = nextBackground;
      _audioVolume = storedVolume;
    });
    _services.onBackgroundMusicEnabledChanged(_effectiveBackgroundMusicEnabled);
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
