import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/controller_startup_coordinator.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/debug_scenarios.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/app/preferences_store.dart';

part 'sudoku_controller_internal.dart';

class SudokuController extends ChangeNotifier {
  final GameService _service;
  late SettingsController _settings;
  late final GameSessionService _sessionService;
  late final SolutionCheckCoordinator _solutionCoordinator;
  late final UiStateMapper _uiStateMapper;
  late final BoardEditCoordinator _boardEditCoordinator;
  late final ControllerStartupCoordinator _startupCoordinator;
  late final ContradictionService _contradictionService;
  late final CorrectionRecoveryService _correctionRecoveryService;
  late SudokuRuntimeState _runtime;
  bool _hadSavedSessionAtLaunch = false;

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
  }) : _service = gameService ?? GameService() {
    final prefs = preferencesStore ?? PreferencesStore();
    final resolvedGridUtils = gridUtils ?? GridUtils();
    final resolvedCheckService = checkService ?? CheckService();
    _settings =
        settingsController ?? SettingsController(prefs, notifyListeners);
    _sessionService =
        gameSessionService ?? GameSessionService(prefs, resolvedGridUtils);
    _solutionCoordinator =
        solutionCheckCoordinator ??
        SolutionCheckCoordinator(resolvedCheckService, resolvedGridUtils);
    _uiStateMapper = uiStateMapper ?? const UiStateMapper();
    _boardEditCoordinator =
        boardEditCoordinator ?? BoardEditCoordinator(_service);
    _startupCoordinator =
        startupCoordinator ??
        ControllerStartupCoordinator(_settings, _sessionService);
    _contradictionService =
        contradictionService ?? const ContradictionService();
    _correctionRecoveryService =
        correctionRecoveryService ??
        CorrectionRecoveryService(contradictionService: _contradictionService);
    final history = _service.initialHistory();
    _runtime = SudokuRuntimeState(
      history: history,
      correctionState: CorrectionState.initial(
        difficulty: _settings.state.difficulty,
        history: history,
      ),
    );
    ready = _initialize();
  }

  late final Future<void> ready;
  bool get hadSavedSessionAtLaunch => _hadSavedSessionAtLaunch;

  Future<void> _initialize() async {
    final startup = await _startupCoordinator.initialize();
    final restoredSession = startup.restoredSession;
    _hadSavedSessionAtLaunch = startup.shouldResumeSession;
    if (startup.shouldResumeSession && restoredSession != null) {
      _runtime = SudokuRuntimeState(
        history: restoredSession.history,
        correctionState: restoredSession.correctionState,
        selected: restoredSession.selected,
        gameOver: restoredSession.gameOver,
        initialGrid: restoredSession.initialGrid,
        debugScenarioLabel: restoredSession.debugScenarioLabel,
      );
      _applyRestoredSettings(restoredSession.settings);
      notifyListeners();
      return;
    }
    if (restoredSession != null) {
      _applyRestoredSettings(restoredSession.settings);
    }
    start();
  }

  UiState get state => _buildState();

  void start() {
    _startPuzzle();
  }

  void onCellTapped(Coord coord) {
    if (_runtime.gameOver) {
      return;
    }
    final cell = _runtime.history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    _runtime.selected = coord;
    _queueCorrectionPromptForSelection(coord);
    _saveGameSession();
    _render('Cell selected');
  }

  void onDigitPressed(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onDigitPressed(
        gameOver: _runtime.gameOver,
        selected: _runtime.selected,
        notesMode: _settings.state.notesMode,
        history: _runtime.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onPlaceDigit(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onPlaceDigit(
        gameOver: _runtime.gameOver,
        selected: _runtime.selected,
        history: _runtime.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onClearPressed() {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onClearPressed(
        gameOver: _runtime.gameOver,
        selected: _runtime.selected,
        notesMode: _settings.state.notesMode,
        history: _runtime.history,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onToggleNotesMode() {
    if (_runtime.gameOver) {
      return;
    }
    _settings.toggleNotesMode();
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void setNotesMode(bool enabled) {
    if (_runtime.gameOver) {
      return;
    }
    _settings.setNotesMode(enabled);
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onNewGame() {
    _startPuzzle();
  }

  void onLoadCorrectionScenario() {
    final scenario = DebugScenarios.correctionRecovery(
      service: _service,
      currentSettings: _settings.state,
      tokensLeft:
          _runtime.debugScenarioLabel == 'Debug scenario: correction available'
          ? _runtime.correctionState.tokensLeft
          : null,
    );
    _applyDebugScenario(scenario, 'Debug correction scenario loaded');
  }

  void onLoadExhaustedCorrectionScenario() {
    final scenario = DebugScenarios.exhaustedCorrectionRecovery(
      service: _service,
      currentSettings: _settings.state,
    );
    _applyDebugScenario(
      scenario,
      'Debug exhausted-corrections scenario loaded',
    );
  }

  void _applyDebugScenario(DebugScenario scenario, String status) {
    _runtime
      ..debugScenarioLabel = scenario.label
      ..history = scenario.history
      ..correctionState = scenario.correctionState
      ..selected = scenario.selected
      ..initialGrid = scenario.initialGrid
      ..lastConflicts = _contradictionService
          .analyze(scenario.history.present.board)
          .contradictionCells
      ..incorrectCells = {}
      ..solutionAddedCells = {}
      ..correctCells = {}
      ..solutionGrid = null
      ..gameOver = false;
    _applyRestoredSettings(scenario.settings);
    _saveGameSession();
    _render(status);
  }

  void onUndo() {
    if (_runtime.gameOver) {
      return;
    }
    final res = _service.undo(_runtime.history);
    if (res.history == _runtime.history) {
      _render(res.message);
      return;
    }

    final nextMoveId = _runtime.correctionState.currentMoveId > 0
        ? _runtime.correctionState.currentMoveId - 1
        : 0;
    _runtime.history = res.history;
    _runtime.lastConflicts = _contradictionService
        .analyze(_runtime.history.present.board)
        .contradictionCells;
    _runtime.correctionState = _runtime.correctionState.copyWith(
      currentMoveId: nextMoveId,
      checkpoints: _runtime.correctionState.prunedToMoveId(nextMoveId),
      revertedCells: const {},
      pendingPromptCoord: null,
    );
    _saveGameSession();
    _render(res.message);
  }

  void onSetDifficulty(String difficulty) {
    final d = difficulty.trim().toLowerCase();
    if (!['easy', 'medium', 'hard'].contains(d)) {
      _render('Unknown difficulty: $difficulty');
      return;
    }
    if (!_settings.state.canChangeDifficulty) {
      _render('Finish or start a new game before changing difficulty');
      return;
    }
    if (!_settings.setDifficulty(d)) {
      return;
    }
    _settings.setPuzzleMode(_defaultPuzzleModeForDifficulty(d));
    _startPuzzle();
  }

  void onStyleChanged(String styleName) {
    _settings.setStyleName(styleName);
    _render('Style: $styleName');
  }

  void onContentModeChanged(String mode) {
    final next = (mode == 'animals') ? 'animals' : 'numbers';
    _settings.setContentMode(next);
    _render('Mode: ${next == 'animals' ? 'Animals' : 'Numbers'}');
  }

  void onAnimalStyleChanged(String style) {
    final next = style == 'cute' ? 'cute' : 'simple';
    _settings.setAnimalStyle(next);
    _render('Animal style: $next');
  }

  void onPuzzleModeChanged(String mode) {
    if (!_settings.state.canChangePuzzleMode) {
      _render('Finish or check the game before changing puzzle mode');
      return;
    }
    if (_settings.state.difficulty == 'hard') {
      _settings.setPuzzleMode('unique');
      _render('Puzzle mode: unique');
      return;
    }
    final next = mode == 'unique' ? 'unique' : 'multi';
    _settings.setPuzzleMode(next);
    _startPuzzle();
  }

  void onCheckSolution() {
    _onCheckSolutionInternal(this);
  }

  void onShowSolution() {
    _onShowSolutionInternal(this);
  }

  void onConfirmCorrection() {
    _onConfirmCorrectionInternal(this);
  }

  void onDismissCorrectionPrompt() {
    _onDismissCorrectionPromptInternal(this);
  }

  void _applyBoardEditOutcome(BoardEditOutcome outcome) {
    _applyBoardEditOutcomeInternal(this, outcome);
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _applyResultInternal(this, res, statusOverride: statusOverride);
  }

  void _applyPlayerResult(MoveResult res, {required bool boardChanged}) {
    _applyPlayerResultInternal(this, res, boardChanged: boardChanged);
  }

  void _render(String status) {
    notifyListeners();
  }

  UiState _buildState() {
    return _buildStateInternal(this);
  }

  String _defaultPuzzleModeForDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      return 'multi';
    }
    return 'unique';
  }

  Set<Coord> _givenCoords() {
    return _givenCoordsInternal(this);
  }

  void _saveGameSession() {
    _saveGameSessionInternal(this);
  }

  Future<void> flushGameSession() {
    return _sessionService.flushPendingSave();
  }

  void _startPuzzle() {
    _startPuzzleInternal(this);
  }

  void _resetBoardFlags() {
    _resetBoardFlagsInternal(this);
  }

  void _applyRestoredSettings(SettingsState settings) {
    _applyRestoredSettingsInternal(this, settings);
  }

  void _clearCorrectionPromptState({required bool clearRevertedCells}) {
    _clearCorrectionPromptStateInternal(
      this,
      clearRevertedCells: clearRevertedCells,
    );
  }

  Set<Coord> _changedCells(Board from, Board to) {
    return _changedCellsInternal(this, from, to);
  }

  void _queueCorrectionPromptForSelection(Coord coord) {
    _queueCorrectionPromptForSelectionInternal(this, coord);
  }
}
