part of 'game_controller.dart';

extension GameControllerActions on GameController {
  void onLoadCorrectionScenario(VoidCallback notifyListeners) {
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
    _configurationService.setDifficulty(
      settings: _settings,
      entitlement: _entitlement,
      difficulty: difficulty,
      startGame: () => start(notifyListeners),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onPuzzleModeChanged(String mode, VoidCallback notifyListeners) {
    _configurationService.setPuzzleMode(
      settings: _settings,
      mode: mode,
      startGame: () => start(notifyListeners),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onCheckSolution(VoidCallback notifyListeners) {
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
    _recordPuzzleCompletionIfNeeded(wasPuzzleSolved: wasPuzzleSolved);
  }

  void onShowSolution(VoidCallback notifyListeners) {
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
    _recordPuzzleCompletionIfNeeded(wasPuzzleSolved: wasPuzzleSolved);
  }

  void onCompletePuzzleWithSolution(VoidCallback notifyListeners) {
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
    _recordPuzzleCompletionIfNeeded(wasPuzzleSolved: wasPuzzleSolved);
  }

  void onConfirmCorrection(VoidCallback notifyListeners) {
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
