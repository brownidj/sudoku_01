import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/game_configuration_service.dart';
import 'package:flutter_app/app/game_controller_effects.dart';
import 'package:flutter_app/app/game_scenario_service.dart';
import 'package:flutter_app/app/game_startup_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller_action_service.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class GameController {
  final SettingsController _settings;
  final SudokuControllerActionService _actionService;
  final GameControllerEffects _effects;
  final GameStartupService _startupService;
  final GameScenarioService _scenarioService;
  final GameConfigurationService _configurationService;
  final SudokuRuntimeStateService _runtimeStateService;
  final UiStateMapper _uiStateMapper;
  late SudokuRuntimeState _runtime;
  bool _hadSavedSessionAtLaunch = false;

  GameController({
    required SettingsController settingsController,
    required SudokuRuntimeStateService runtimeStateService,
    required SudokuControllerActionService actionService,
    required GameControllerEffects effects,
    required GameStartupService startupService,
    required GameScenarioService scenarioService,
    required GameConfigurationService configurationService,
    required UiStateMapper uiStateMapper,
    required GameService gameService,
  }) : _settings = settingsController,
       _runtimeStateService = runtimeStateService,
       _actionService = actionService,
       _effects = effects,
       _startupService = startupService,
       _scenarioService = scenarioService,
       _configurationService = configurationService,
       _uiStateMapper = uiStateMapper {
    final history = gameService.initialHistory();
    _runtime = SudokuRuntimeState(
      history: history,
      correctionState: _runtimeStateService.initialCorrectionState(
        difficulty: _settings.state.difficulty,
        history: history,
      ),
      conflictHintsLeft: conflictHintsForDifficulty(_settings.state.difficulty),
    );
  }

  UiState get state => _runtimeStateService.buildState(
    runtime: _runtime,
    settings: _settings.state,
    uiStateMapper: _uiStateMapper,
  );
  SettingsState get settingsState => _settings.state;
  bool get hadSavedSessionAtLaunch => _hadSavedSessionAtLaunch;
  bool get gameOver => _runtime.gameOver;
  History get history => _runtime.history;
  Coord? get selected => _runtime.selected;

  Future<void> initialize(VoidCallback notifyListeners) async {
    final startup = await _startupService.initialize(_settings);
    _hadSavedSessionAtLaunch = startup.hadSavedSessionAtLaunch;
    if (startup.restoredRuntime != null) {
      _runtime = startup.restoredRuntime!;
    }
    if (startup.shouldNotifyListeners) {
      _effects.render(notifyListeners, 'Session restored');
      return;
    }
    if (startup.shouldStartNewGame) {
      start(notifyListeners);
    }
  }

  bool isGiven(Coord coord) {
    return _runtime.history.present.board.cellAtCoord(coord).given;
  }

  void selectCell(Coord coord, VoidCallback notifyListeners) {
    if (_runtime.gameOver || isGiven(coord)) {
      return;
    }
    _runtime.selected = coord;
    _actionService.queueCorrectionPromptForSelection(
      runtime: _runtime,
      coord: coord,
    );
    _effects.saveGameSession(runtime: _runtime, settings: _settings.state);
    _effects.render(notifyListeners, 'Cell selected');
  }

  void applyBoardEditOutcome(
    BoardEditOutcome outcome,
    VoidCallback notifyListeners,
  ) {
    _actionService.applyBoardEditOutcome(
      runtime: _runtime,
      settings: _settings,
      outcome: outcome,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void start(VoidCallback notifyListeners) {
    _actionService.startPuzzle(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onNewGame(VoidCallback notifyListeners) {
    start(notifyListeners);
  }

  void onLoadCorrectionScenario(VoidCallback notifyListeners) {
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
    _actionService.checkSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onShowSolution(VoidCallback notifyListeners) {
    _actionService.showSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
  }

  void onCompletePuzzleWithSolution(VoidCallback notifyListeners) {
    _actionService.completePuzzleWithSolution(
      runtime: _runtime,
      settings: _settings,
      saveGameSession: () => _effects.saveGameSession(
        runtime: _runtime,
        settings: _settings.state,
      ),
      render: (status) => _effects.render(notifyListeners, status),
    );
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

  Future<void> flushGameSession() => _effects.flushPendingSave();
}
