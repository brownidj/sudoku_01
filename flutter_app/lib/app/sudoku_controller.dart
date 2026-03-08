import 'dart:async';
import 'dart:convert';

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
  static const int _sessionVersion = 1;

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
  bool _hadSavedSessionAtLaunch = false;

  SudokuController({
    PreferencesStore? preferencesStore,
    GameService? gameService,
    CheckService? checkService,
    GridUtils? gridUtils,
    SettingsController? settingsController,
  }) : _prefs = preferencesStore ?? PreferencesStore(),
       _service = gameService ?? GameService(),
       _checkService = checkService ?? CheckService(),
       _gridUtils = gridUtils ?? GridUtils() {
    _settings =
        settingsController ?? SettingsController(_prefs, notifyListeners);
    _history = _service.initialHistory();
    ready = _initialize();
  }

  late final Future<void> ready;
  bool get hadSavedSessionAtLaunch => _hadSavedSessionAtLaunch;

  Future<void> _initialize() async {
    await _settings.load();
    final restored = await _restoreSavedGame();
    _hadSavedSessionAtLaunch = restored;
    if (!restored) {
      start();
    }
  }

  UiState get state => _buildState();

  void start() {
    final puzzle = puzzles.generatePuzzle(
      _settings.state.difficulty,
      mode: _settings.state.puzzleMode,
    );
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(
      res,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
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
    _lockPuzzleModeIfFirstPlayerChange(before, _history);
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
    _lockPuzzleModeIfFirstPlayerChange(before, _history);
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
    _lockPuzzleModeIfFirstPlayerChange(before, _history);
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
    final puzzle = puzzles.generatePuzzle(
      _settings.state.difficulty,
      mode: _settings.state.puzzleMode,
    );
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(
      res,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
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
    final defaultMode = _defaultPuzzleModeForDifficulty(d);
    _settings.setPuzzleMode(defaultMode);
    final puzzle = puzzles.generatePuzzle(
      _settings.state.difficulty,
      mode: _settings.state.puzzleMode,
    );
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(
      res,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
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
    final puzzle = puzzles.generatePuzzle(
      _settings.state.difficulty,
      mode: _settings.state.puzzleMode,
    );
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _gridUtils.copyGrid(puzzle.grid);
    _applyResult(
      res,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
  }

  void onCheckSolution() {
    if (_gameOver) {
      return;
    }
    final base =
        _initialGrid ?? _gridUtils.gridFromBoard(_history.present.board);
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
    _settings.setPuzzleModeLocked(false);
    _saveGameSession();
    _render('Check complete');
  }

  void onShowSolution() {
    if (!_gameOver) {
      onCheckSolution();
    }
    if (!_gameOver) {
      return;
    }
    final base =
        _initialGrid ?? _gridUtils.gridFromBoard(_history.present.board);
    final current = _gridUtils.gridFromBoard(_history.present.board);
    final result = _checkService.check(
      baseGrid: base,
      currentGrid: current,
      givens: _givenCoords(),
      showSolution: true,
    );
    _incorrectCells = {};
    _correctCells = result.correct;
    _solutionGrid = result.solutionGrid;
    _solutionAddedCells = {...result.solutionAdded, ...result.incorrect};
    _selected = null;
    _settings.setPuzzleModeLocked(false);
    _saveGameSession();
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

  void _lockPuzzleModeIfFirstPlayerChange(History before, History after) {
    if (!_settings.state.canChangePuzzleMode) {
      return;
    }
    if (!before.canUndo() && after.canUndo()) {
      _settings.setPuzzleModeLocked(true);
    }
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _history = res.history;
    _lastConflicts = res.conflicts;
    _saveGameSession();
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
        final solutionAdded = _solutionAddedCells.contains(coord);
        final displayValue = solutionAdded && solutionValue != null
            ? solutionValue
            : (cell.value ?? solutionValue);
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
      canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      styleName: _settings.state.styleName,
      contentMode: _settings.state.contentMode,
      animalStyle: _settings.state.animalStyle,
      puzzleMode: _settings.state.puzzleMode,
      selected: _selected,
      gameOver: _gameOver,
    );
  }

  String _defaultPuzzleModeForDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      return 'multi';
    }
    return 'unique';
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

  Future<bool> _restoreSavedGame() async {
    final raw = await _prefs.loadGameSession();
    if (raw == null || raw.isEmpty) {
      return false;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }
      if (decoded['version'] != _sessionVersion) {
        return false;
      }

      final boardRaw = decoded['board'];
      if (boardRaw is! List) {
        return false;
      }
      final restoredBoard = _boardFromJson(boardRaw);
      if (restoredBoard == null) {
        return false;
      }

      _history = History.initial(GameState(board: restoredBoard));
      _lastConflicts = {};
      _solutionGrid = null;
      _incorrectCells = {};
      _correctCells = {};
      _solutionAddedCells = {};
      _selected = _coordFromJson(decoded['selected']);
      _gameOver = decoded['gameOver'] == true;

      final initialGrid = _gridFromJson(decoded['initialGrid']);
      _initialGrid = initialGrid ?? _gridUtils.gridFromBoard(restoredBoard);

      final settings = decoded['settings'];
      if (settings is Map<String, dynamic>) {
        _restoreSettingsFromSession(settings);
      }

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _restoreSettingsFromSession(Map<String, dynamic> settings) {
    final difficulty = _difficultyOrDefault(settings['difficulty']);
    var puzzleMode = _puzzleModeOrDefault(settings['puzzleMode'], difficulty);
    if (difficulty == 'hard') {
      puzzleMode = 'unique';
    }

    final styleName = _styleOrDefault(settings['styleName']);
    final contentMode = _contentModeOrDefault(settings['contentMode']);
    final animalStyle = _animalStyleOrDefault(settings['animalStyle']);
    final notesMode = settings['notesMode'] == true;
    final canChangeDifficulty = settings['canChangeDifficulty'] != false;
    final canChangePuzzleMode = settings['canChangePuzzleMode'] != false;

    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _settings.setStyleName(styleName);
    _settings.setContentMode(contentMode);
    _settings.setAnimalStyle(animalStyle);
    _settings.setNotesMode(notesMode);
    _settings.setDifficulty(difficulty);
    _settings.setPuzzleMode(puzzleMode);
    _settings.setDifficultyLocked(!canChangeDifficulty);
    _settings.setPuzzleModeLocked(!canChangePuzzleMode);
  }

  void _saveGameSession() {
    final payload = <String, dynamic>{
      'version': _sessionVersion,
      'board': _boardToJson(_history.present.board),
      'initialGrid': _gridToJson(_initialGrid),
      'selected': _coordToJson(_selected),
      'gameOver': _gameOver,
      'settings': <String, dynamic>{
        'notesMode': _settings.state.notesMode,
        'difficulty': _settings.state.difficulty,
        'canChangeDifficulty': _settings.state.canChangeDifficulty,
        'canChangePuzzleMode': _settings.state.canChangePuzzleMode,
        'styleName': _settings.state.styleName,
        'contentMode': _settings.state.contentMode,
        'animalStyle': _settings.state.animalStyle,
        'puzzleMode': _settings.state.puzzleMode,
      },
    };
    unawaited(_prefs.saveGameSession(jsonEncode(payload)));
  }

  List<List<Map<String, dynamic>>> _boardToJson(Board board) {
    return List<List<Map<String, dynamic>>>.generate(9, (r) {
      return List<Map<String, dynamic>>.generate(9, (c) {
        final cell = board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        return <String, dynamic>{'v': cell.value, 'g': cell.given, 'n': notes};
      }, growable: false);
    }, growable: false);
  }

  Board? _boardFromJson(List<dynamic> raw) {
    if (raw.length != 9) {
      return null;
    }
    final rows = <List<Cell>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }
      final row = <Cell>[];
      for (var c = 0; c < 9; c += 1) {
        final cellRaw = rowRaw[c];
        if (cellRaw is! Map<String, dynamic>) {
          return null;
        }
        final valueRaw = cellRaw['v'];
        final value = valueRaw is int ? valueRaw : null;
        final given = cellRaw['g'] == true;
        final notesRaw = cellRaw['n'];
        final notes = <int>{};
        if (notesRaw is List) {
          for (final note in notesRaw) {
            if (note is int && note >= 1 && note <= 9) {
              notes.add(note);
            }
          }
        }
        row.add(Cell(value: value, given: given, notes: notes));
      }
      rows.add(row);
    }
    return Board(cells: rows);
  }

  List<List<int?>>? _gridToJson(Grid? grid) {
    if (grid == null) {
      return null;
    }
    return List<List<int?>>.generate(9, (r) {
      return List<int?>.generate(9, (c) => grid[r][c], growable: false);
    }, growable: false);
  }

  Grid? _gridFromJson(Object? raw) {
    if (raw is! List || raw.length != 9) {
      return null;
    }
    final out = <List<int?>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }
      final row = <int?>[];
      for (var c = 0; c < 9; c += 1) {
        final value = rowRaw[c];
        row.add(value is int ? value : null);
      }
      out.add(row);
    }
    return out;
  }

  Map<String, int>? _coordToJson(Coord? coord) {
    if (coord == null) {
      return null;
    }
    return <String, int>{'row': coord.row, 'col': coord.col};
  }

  Coord? _coordFromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final row = raw['row'];
    final col = raw['col'];
    if (row is! int || col is! int) {
      return null;
    }
    if (row < 0 || row > 8 || col < 0 || col > 8) {
      return null;
    }
    return Coord(row, col);
  }

  String _difficultyOrDefault(Object? raw) {
    final value = (raw is String) ? raw : '';
    if (value == 'easy' || value == 'medium' || value == 'hard') {
      return value;
    }
    return _settings.state.difficulty;
  }

  String _puzzleModeOrDefault(Object? raw, String difficulty) {
    final value = (raw is String) ? raw : '';
    if (value == 'unique' || value == 'multi') {
      return value;
    }
    return _defaultPuzzleModeForDifficulty(difficulty);
  }

  String _styleOrDefault(Object? raw) {
    final value = (raw is String) ? raw : '';
    if (value == 'Modern' || value == 'Classic' || value == 'High Contrast') {
      return value;
    }
    return _settings.state.styleName;
  }

  String _contentModeOrDefault(Object? raw) {
    final value = (raw is String) ? raw : '';
    if (value == 'animals' || value == 'numbers') {
      return value;
    }
    return _settings.state.contentMode;
  }

  String _animalStyleOrDefault(Object? raw) {
    final value = (raw is String) ? raw : '';
    if (value == 'cute' || value == 'simple') {
      return value;
    }
    return _settings.state.animalStyle;
  }
}
