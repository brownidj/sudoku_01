import 'package:flutter/foundation.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/app/preferences_store.dart';

class SudokuController extends ChangeNotifier {
  final GameService _service;
  final PreferencesStore _prefs;
  late SettingsController _settings;
  final CheckService _checkService;
  final GridUtils _gridUtils;
  late History _history;
  Coord? _selected;
  Set<Coord> _lastConflicts = {};
  // Settings are managed by SettingsController.
  bool _gameOver = false;
  Set<Coord> _incorrectCells = {};
  Set<Coord> _solutionAddedCells = {};
  Set<Coord> _correctCells = {};
  Grid? _solutionGrid;
  Grid? _initialGrid;

  SudokuController({
    PreferencesStore? preferencesStore,
    GameService? gameService,
    CheckService? checkService,
    GridUtils? gridUtils,
    SettingsController? settingsController,
  })  : _prefs = preferencesStore ?? PreferencesStore(),
        _service = gameService ?? GameService(),
        _checkService = checkService ?? CheckService(),
        _gridUtils = gridUtils ?? GridUtils() {
    _settings = settingsController ?? SettingsController(_prefs, notifyListeners);
    _history = _service.initialHistory();
    start();
    ready = _settings.load();
  }

  late final Future<void> ready;

  UiState get state => _buildState();

  void start() {
    final puzzle = puzzles.generatePuzzle(_settings.state.difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
  }

  void onCellTapped(Coord coord) {
    if (_gameOver) {
      return;
    }
    final cell = _history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    _selected = coord;
    _render('Cell selected');
  }

  void onDigitPressed(Digit digit) {
    if (_gameOver) {
      return;
    }
    if (_selected == null) {
      _render('Select a cell');
      return;
    }
    final before = _history;
    final res = _settings.state.notesMode
        ? _service.toggleNote(_history, _selected!, digit)
        : _service.placeDigit(_history, _selected!, digit);
    _applyResult(res);
    _lockDifficultyIfFirstPlayerChange(before, _history);
  }

  void onPlaceDigit(Digit digit) {
    if (_gameOver) {
      return;
    }
    if (_selected == null) {
      return;
    }
    final before = _history;
    final res = _service.placeDigit(_history, _selected!, digit);
    _applyResult(res);
    _lockDifficultyIfFirstPlayerChange(before, _history);
  }

  void onClearPressed() {
    if (_gameOver) {
      return;
    }
    if (_selected == null) {
      _render('Select a cell');
      return;
    }
    final before = _history;
    final res = _settings.state.notesMode
        ? _service.clearNotes(_history, _selected!)
        : _service.clearCell(_history, _selected!);
    _applyResult(res);
    _lockDifficultyIfFirstPlayerChange(before, _history);
  }

  void onToggleNotesMode() {
    if (_gameOver) {
      return;
    }
    _settings.toggleNotesMode();
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void setNotesMode(bool enabled) {
    if (_gameOver) {
      return;
    }
    _settings.setNotesMode(enabled);
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onNewGame() {
    final puzzle = puzzles.generatePuzzle(_settings.state.difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
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
    final puzzle = puzzles.generatePuzzle(_settings.state.difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
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

  void onCheckSolution() {
    if (_gameOver) {
      return;
    }
    final base = _initialGrid ?? _gridUtils.gridFromBoard(_history.present.board);
    final current = _gridUtils.gridFromBoard(_history.present.board);
    final result = _checkService.check(
      baseGrid: base,
      currentGrid: current,
      givens: _givenCoords(),
      showSolution: false,
    );
    _incorrectCells = result.incorrect;
    _correctCells = result.correct;
    _solutionGrid = null;
    _solutionAddedCells = {};
    _selected = null;
    _gameOver = true;
    _render('Check complete');
  }

  void onShowSolution() {
    if (!_gameOver) {
      return;
    }
    final base = _initialGrid ?? _gridUtils.gridFromBoard(_history.present.board);
    final current = _gridUtils.gridFromBoard(_history.present.board);
    final result = _checkService.check(
      baseGrid: base,
      currentGrid: current,
      givens: _givenCoords(),
      showSolution: true,
    );
    _incorrectCells = result.incorrect;
    _correctCells = result.correct;
    _solutionGrid = result.solutionGrid;
    _solutionAddedCells = result.solutionAdded;
    _selected = null;
    _render('Solution');
  }

  void _lockDifficultyIfFirstPlayerChange(History before, History after) {
    if (!_settings.state.canChangeDifficulty) {
      return;
    }
    if (!before.canUndo() && after.canUndo()) {
      _settings.setDifficultyLocked(true);
    }
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _history = res.history;
    _lastConflicts = res.conflicts;
    _render(statusOverride ?? res.message);
  }

  void _render(String status) {
    notifyListeners();
  }

  UiState _buildState() {
    final board = _history.present.board;
    final cells = <List<CellVm>>[];
    final solution = _solutionGrid;
    for (var r = 0; r < 9; r += 1) {
      final row = <CellVm>[];
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        final cell = board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        final solutionValue = solution != null ? solution[r][c] : null;
        final displayValue = cell.value ?? solutionValue;
        final solutionAdded = _solutionAddedCells.contains(coord);
        row.add(
          CellVm(
            coord: coord,
            value: displayValue,
            given: cell.given && !solutionAdded,
            notes: notes,
            selected: coord == _selected,
            conflicted: _lastConflicts.contains(coord),
            incorrect: _incorrectCells.contains(coord),
            solutionAdded: solutionAdded,
            correct: _correctCells.contains(coord),
          ),
        );
      }
      cells.add(row);
    }

    return UiState(
      board: BoardVm(cells: cells),
      notesMode: _settings.state.notesMode,
      difficulty: _settings.state.difficulty,
      canChangeDifficulty: _settings.state.canChangeDifficulty,
      styleName: _settings.state.styleName,
      contentMode: _settings.state.contentMode,
      animalStyle: _settings.state.animalStyle,
      selected: _selected,
      gameOver: _gameOver,
    );
  }

  Set<Coord> _givenCoords() {
    final givens = <Coord>{};
    final board = _history.present.board;
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        if (board.cellAt(r, c).given) {
          givens.add(Coord(r, c));
        }
      }
    }
    return givens;
  }

  // Preferences are handled by SettingsController.
}
