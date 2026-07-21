part of 'game_controller.dart';

extension GameControllerActions on GameController {
  void onLoadCorrectionScenario(VoidCallback notifyListeners) {
    registerActiveUse();
    _completionRecordedForCurrentPuzzle = false;
    _scenarioService.loadCorrectionScenario(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onLoadExhaustedCorrectionScenario(VoidCallback notifyListeners) {
    registerActiveUse();
    _completionRecordedForCurrentPuzzle = false;
    _scenarioService.loadExhaustedCorrectionScenario(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onUndo(VoidCallback notifyListeners) {
    registerActiveUse();
    _scenarioService.undo(
      runtime: _runtime,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onSetDifficulty(String difficulty, VoidCallback notifyListeners) {
    registerActiveUse();
    _configurationService.setDifficulty(
      settings: _settings,
      entitlement: _entitlement,
      difficulty: difficulty,
      startGame: () => start(notifyListeners),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onPuzzleModeChanged(String mode, VoidCallback notifyListeners) {
    registerActiveUse();
    _configurationService.setPuzzleMode(
      settings: _settings,
      mode: mode,
      startGame: () => start(notifyListeners),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onCheckSolution(VoidCallback notifyListeners) {
    registerActiveUse();
    final wasPuzzleSolved = _runtime.puzzleSolved;
    _actionService.checkSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
    _recordPuzzleCompletionIfNeeded(
      wasPuzzleSolved: wasPuzzleSolved,
      notifyListeners: notifyListeners,
    );
  }

  void onShowSolution(VoidCallback notifyListeners) {
    registerActiveUse();
    final wasPuzzleSolved = _runtime.puzzleSolved;
    _actionService.showSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
    _recordPuzzleCompletionIfNeeded(
      wasPuzzleSolved: wasPuzzleSolved,
      notifyListeners: notifyListeners,
    );
    if (_runtime.gameOver) {
      _runtimeStateService.pauseActiveTiming(_runtime);
      _effects.saveGameSession(runtime: _runtime, settings: _settings.state);
    }
  }

  void onCompletePuzzleWithSolution(VoidCallback notifyListeners) {
    registerActiveUse();
    final wasPuzzleSolved = _runtime.puzzleSolved;
    _actionService.completePuzzleWithSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
    _recordPuzzleCompletionIfNeeded(
      wasPuzzleSolved: wasPuzzleSolved,
      notifyListeners: notifyListeners,
    );
  }

  void onConfirmCorrection(VoidCallback notifyListeners) {
    registerActiveUse();
    _actionService.confirmCorrection(
      runtime: _runtime,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onDismissCorrectionPrompt(VoidCallback notifyListeners) {
    registerActiveUse();
    _actionService.dismissCorrectionPrompt(
      runtime: _runtime,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      notifyListeners: notifyListeners,
    );
  }
}
