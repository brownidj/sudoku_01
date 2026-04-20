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

  void _onAudioEnabledChanged(bool enabled) {
    if (_audioEnabled == enabled) {
      return;
    }
    setState(() {
      _audioEnabled = enabled;
    });
    _services.onAudioEnabledChanged(enabled);
  }
}
