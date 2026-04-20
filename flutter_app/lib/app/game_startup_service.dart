import 'package:flutter_app/app/controller_startup_coordinator.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';

class GameStartupOutcome {
  final SudokuRuntimeState? restoredRuntime;
  final bool hadSavedSessionAtLaunch;
  final bool shouldNotifyListeners;
  final bool shouldStartNewGame;

  const GameStartupOutcome({
    required this.restoredRuntime,
    required this.hadSavedSessionAtLaunch,
    required this.shouldNotifyListeners,
    required this.shouldStartNewGame,
  });
}

class GameStartupService {
  final ControllerStartupCoordinator _startupCoordinator;
  final SudokuRuntimeStateService _runtimeStateService;

  const GameStartupService({
    required ControllerStartupCoordinator startupCoordinator,
    required SudokuRuntimeStateService runtimeStateService,
  }) : _startupCoordinator = startupCoordinator,
       _runtimeStateService = runtimeStateService;

  Future<GameStartupOutcome> initialize(SettingsController settings) async {
    final startup = await _startupCoordinator.initialize();
    final restoredSession = startup.restoredSession;
    if (startup.shouldResumeSession && restoredSession != null) {
      _runtimeStateService.applyRestoredSettings(
        settings,
        restoredSession.settings,
      );
      return GameStartupOutcome(
        restoredRuntime: SudokuRuntimeState(
          history: restoredSession.history,
          correctionState: restoredSession.correctionState,
          selected: restoredSession.selected,
          gameOver: restoredSession.gameOver,
          puzzleSolved: restoredSession.puzzleSolved,
          initialGrid: restoredSession.initialGrid,
          debugScenarioLabel: restoredSession.debugScenarioLabel,
          conflictHintsLeft: restoredSession.conflictHintsLeft,
        ),
        hadSavedSessionAtLaunch: true,
        shouldNotifyListeners: true,
        shouldStartNewGame: false,
      );
    }
    return GameStartupOutcome(
      restoredRuntime: null,
      hadSavedSessionAtLaunch: startup.shouldResumeSession,
      shouldNotifyListeners: false,
      shouldStartNewGame: true,
    );
  }
}
