import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/controller_startup_coordinator.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/game_configuration_service.dart';
import 'package:flutter_app/app/game_controller.dart';
import 'package:flutter_app/app/game_controller_effects.dart';
import 'package:flutter_app/app/game_scenario_service.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/game_startup_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/sudoku_controller_action_service.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/app/ui_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuController extends ChangeNotifier {
  late final GameController _gameController;
  late final UiController _uiController;
  late final Future<void> ready;

  SudokuController({
    PreferencesStore? preferencesStore,
    GameService? gameService,
    CheckService? checkService,
    GridUtils? gridUtils,
    SettingsController? settingsController,
    GameSessionService? gameSessionService,
    SolutionCheckCoordinator? solutionCheckCoordinator,
    UiStateMapper? uiStateMapper,
    BoardEditCoordinator? boardEditCoordinator,
    ControllerStartupCoordinator? startupCoordinator,
    ContradictionService? contradictionService,
    CorrectionRecoveryService? correctionRecoveryService,
    SudokuRuntimeStateService? runtimeStateService,
    SudokuControllerActionService? actionService,
  }) {
    final prefs = preferencesStore ?? PreferencesStore();
    final resolvedGameService = gameService ?? GameService();
    final resolvedGridUtils = gridUtils ?? GridUtils();
    final resolvedCheckService = checkService ?? CheckService();
    final resolvedSettingsController =
        settingsController ?? SettingsController(prefs, notifyListeners);
    final resolvedSessionService =
        gameSessionService ?? GameSessionService(prefs, resolvedGridUtils);
    final resolvedSolutionCoordinator =
        solutionCheckCoordinator ??
        SolutionCheckCoordinator(resolvedCheckService, resolvedGridUtils);
    final resolvedUiStateMapper = uiStateMapper ?? const UiStateMapper();
    final resolvedBoardEditCoordinator =
        boardEditCoordinator ?? BoardEditCoordinator(resolvedGameService);
    final resolvedStartupCoordinator =
        startupCoordinator ??
        ControllerStartupCoordinator(
          resolvedSettingsController,
          resolvedSessionService,
        );
    final resolvedContradictionService =
        contradictionService ?? const ContradictionService();
    final resolvedCorrectionRecoveryService =
        correctionRecoveryService ??
        CorrectionRecoveryService(
          contradictionService: resolvedContradictionService,
        );
    final resolvedRuntimeStateService =
        runtimeStateService ?? const SudokuRuntimeStateService();
    final resolvedActionService =
        actionService ??
        SudokuControllerActionService(
          gameService: resolvedGameService,
          solutionCoordinator: resolvedSolutionCoordinator,
          contradictionService: resolvedContradictionService,
          correctionRecoveryService: resolvedCorrectionRecoveryService,
          runtimeStateService: resolvedRuntimeStateService,
        );
    final resolvedEffects = GameControllerEffects(resolvedSessionService);
    final resolvedStartupService = GameStartupService(
      startupCoordinator: resolvedStartupCoordinator,
      runtimeStateService: resolvedRuntimeStateService,
    );
    final resolvedScenarioService = GameScenarioService(
      gameService: resolvedGameService,
      contradictionService: resolvedContradictionService,
      runtimeStateService: resolvedRuntimeStateService,
    );
    const resolvedConfigurationService = GameConfigurationService();

    _gameController = GameController(
      settingsController: resolvedSettingsController,
      runtimeStateService: resolvedRuntimeStateService,
      actionService: resolvedActionService,
      effects: resolvedEffects,
      startupService: resolvedStartupService,
      scenarioService: resolvedScenarioService,
      configurationService: resolvedConfigurationService,
      uiStateMapper: resolvedUiStateMapper,
      gameService: resolvedGameService,
    );
    _uiController = UiController(
      gameController: _gameController,
      settingsController: resolvedSettingsController,
      boardEditCoordinator: resolvedBoardEditCoordinator,
    );
    ready = _gameController.initialize(notifyListeners);
  }

  UiState get state => _gameController.state;
  bool get hadSavedSessionAtLaunch => _gameController.hadSavedSessionAtLaunch;
  bool get isCurrentGameResumed => _gameController.isCurrentGameResumed;

  void start() => _gameController.start(notifyListeners);
  void onCellTapped(Coord coord) =>
      _uiController.onCellTapped(coord, notifyListeners);
  void onDigitPressed(Digit digit) =>
      _uiController.onDigitPressed(digit, notifyListeners);
  void onPlaceDigit(Digit digit) =>
      _uiController.onPlaceDigit(digit, notifyListeners);
  void onClearPressed() => _uiController.onClearPressed(notifyListeners);
  void onToggleNotesMode() => _uiController.onToggleNotesMode(notifyListeners);
  void setNotesMode(bool enabled) =>
      _uiController.setNotesMode(enabled, notifyListeners);
  void onNewGame() => _gameController.onNewGame(notifyListeners);
  void onLoadCorrectionScenario() =>
      _gameController.onLoadCorrectionScenario(notifyListeners);
  void onLoadExhaustedCorrectionScenario() =>
      _gameController.onLoadExhaustedCorrectionScenario(notifyListeners);
  void onUndo() => _gameController.onUndo(notifyListeners);
  void onSetDifficulty(String difficulty) =>
      _gameController.onSetDifficulty(difficulty, notifyListeners);
  void onConfirmSetDifficulty(String difficulty) =>
      _gameController.onConfirmSetDifficulty(difficulty, notifyListeners);
  void onStyleChanged(String styleName) =>
      _uiController.onStyleChanged(styleName, notifyListeners);
  void onContentModeChanged(String mode) =>
      _uiController.onContentModeChanged(mode, notifyListeners);
  void onAnimalStyleChanged(String style) =>
      _uiController.onAnimalStyleChanged(style, notifyListeners);
  void onPuzzleModeChanged(String mode) =>
      _gameController.onPuzzleModeChanged(mode, notifyListeners);
  void onConfirmPuzzleModeChanged(String mode) =>
      _gameController.onConfirmPuzzleModeChanged(mode, notifyListeners);
  void onCheckSolution() => _gameController.onCheckSolution(notifyListeners);
  void onShowSolution() => _gameController.onShowSolution(notifyListeners);
  void onCompletePuzzleWithSolution() =>
      _gameController.onCompletePuzzleWithSolution(notifyListeners);
  void onConfirmCorrection() =>
      _gameController.onConfirmCorrection(notifyListeners);
  void onDismissCorrectionPrompt() =>
      _gameController.onDismissCorrectionPrompt(notifyListeners);
  Future<void> flushGameSession() => _gameController.flushGameSession();
}
