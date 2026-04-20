import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/progress_metrics_service.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/entitlement_sync_service.dart';
import 'package:flutter_app/app/game_configuration_service.dart';
import 'package:flutter_app/app/game_controller_effects.dart';
import 'package:flutter_app/app/game_scenario_service.dart';
import 'package:flutter_app/app/game_startup_service.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
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

part 'game_controller_actions.dart';

class GameController {
  final SettingsController _settings;
  final SudokuControllerActionService _actionService;
  final GameControllerEffects _effects;
  final GameStartupService _startupService;
  final GameScenarioService _scenarioService;
  final GameConfigurationService _configurationService;
  final PremiumPolicyService _premiumPolicyService;
  final ProgressMetricsService _progressMetricsService;
  final EntitlementSyncService _entitlementSyncService;
  final SudokuRuntimeStateService _runtimeStateService;
  final UiStateMapper _uiStateMapper;
  late SudokuRuntimeState _runtime;
  bool _hadSavedSessionAtLaunch = false;
  bool _completionRecordedForCurrentPuzzle = false;
  int _completedPuzzles = 0;
  Entitlement _entitlement = Entitlement.free;

  GameController({
    required SettingsController settingsController,
    required SudokuRuntimeStateService runtimeStateService,
    required SudokuControllerActionService actionService,
    required GameControllerEffects effects,
    required GameStartupService startupService,
    required GameScenarioService scenarioService,
    required GameConfigurationService configurationService,
    required PremiumPolicyService premiumPolicyService,
    required ProgressMetricsService progressMetricsService,
    required EntitlementSyncService entitlementSyncService,
    required UiStateMapper uiStateMapper,
    required GameService gameService,
  }) : _settings = settingsController,
       _runtimeStateService = runtimeStateService,
       _actionService = actionService,
       _effects = effects,
       _startupService = startupService,
       _scenarioService = scenarioService,
       _configurationService = configurationService,
       _premiumPolicyService = premiumPolicyService,
       _progressMetricsService = progressMetricsService,
       _entitlementSyncService = entitlementSyncService,
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
    entitlement: _entitlement,
    premiumActive: _premiumPolicyService.isPremiumActive(_entitlement),
  );
  SettingsState get settingsState => _settings.state;
  bool get hadSavedSessionAtLaunch => _hadSavedSessionAtLaunch;
  int get completedPuzzles => _completedPuzzles;
  Entitlement get entitlement => _entitlement;
  bool get gameOver => _runtime.gameOver;
  History get history => _runtime.history;
  Coord? get selected => _runtime.selected;

  Future<void> initialize(VoidCallback notifyListeners) async {
    _entitlement = await _entitlementSyncService.loadStartupEntitlement(
      fallback: _entitlement,
    );
    _completedPuzzles = await _progressMetricsService.loadCompletedPuzzles();
    final startup = await _startupService.initialize(_settings);
    _hadSavedSessionAtLaunch = startup.hadSavedSessionAtLaunch;
    if (startup.restoredRuntime != null) {
      _runtime = startup.restoredRuntime!;
      _completionRecordedForCurrentPuzzle = _runtime.puzzleSolved;
    }
    if (startup.shouldNotifyListeners) {
      _effects.render(notifyListeners, 'Session restored');
      return;
    }
    if (startup.shouldStartNewGame) {
      start(notifyListeners);
    }
  }

  bool isGiven(Coord coord) =>
      _runtime.history.present.board.cellAtCoord(coord).given;

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
    final wasPuzzleSolved = _runtime.puzzleSolved;
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
    _recordPuzzleCompletionIfNeeded(wasPuzzleSolved: wasPuzzleSolved);
  }

  void start(VoidCallback notifyListeners) {
    _completionRecordedForCurrentPuzzle = false;
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

  void onNewGame(VoidCallback notifyListeners) => start(notifyListeners);

  bool isDifficultyUnlocked(String difficulty) =>
      _premiumPolicyService.isDifficultyUnlocked(difficulty, _entitlement);

  Future<void> flushGameSession() => _effects.flushPendingSave();

  Future<void> refreshEntitlement(VoidCallback notifyListeners) async {
    final refreshed = await _entitlementSyncService.refreshEntitlement(
      fallback: _entitlement,
    );
    if (_entitlement == refreshed) {
      return;
    }
    _entitlement = refreshed;
    _effects.render(notifyListeners, 'Entitlement refreshed');
  }

  void persistCurrentSession() {
    _effects.saveGameSession(runtime: _runtime, settings: _settings.state);
  }

  void setEntitlement(Entitlement entitlement, VoidCallback notifyListeners) {
    if (_entitlement == entitlement) {
      return;
    }
    _entitlement = entitlement;
    unawaited(_entitlementSyncService.persistEntitlement(entitlement));
    _effects.render(notifyListeners, 'Entitlement updated');
  }

  void _recordPuzzleCompletionIfNeeded({required bool wasPuzzleSolved}) {
    if (wasPuzzleSolved ||
        !_runtime.puzzleSolved ||
        _completionRecordedForCurrentPuzzle) {
      return;
    }
    _completionRecordedForCurrentPuzzle = true;
    _completedPuzzles += 1;
    unawaited(_progressMetricsService.saveCompletedPuzzles(_completedPuzzles));
  }
}
