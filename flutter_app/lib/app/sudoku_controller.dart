import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/solver.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/app/preferences_store.dart';

class CellVm {
  final Coord coord;
  final Digit? value;
  final bool given;
  final List<Digit> notes;
  final bool selected;
  final bool conflicted;
  final bool incorrect;
  final bool solutionAdded;
  final bool correct;

  const CellVm({
    required this.coord,
    required this.value,
    required this.given,
    required this.notes,
    required this.selected,
    required this.conflicted,
    required this.incorrect,
    required this.solutionAdded,
    required this.correct,
  });
}

class BoardVm {
  final List<List<CellVm>> cells;

  const BoardVm({required this.cells});
}

class UiState {
  final BoardVm board;
  final String statusText;
  final bool notesMode;
  final bool canUndo;
  final bool canRedo;
  final bool solved;
  final String difficulty;
  final bool canChangeDifficulty;
  final String styleName;
  final String contentMode;
  final String animalStyle;
  final Coord? selected;
  final bool gameOver;

  const UiState({
    required this.board,
    required this.statusText,
    required this.notesMode,
    required this.canUndo,
    required this.canRedo,
    required this.solved,
    required this.difficulty,
    required this.canChangeDifficulty,
    required this.styleName,
    required this.contentMode,
    required this.animalStyle,
    required this.selected,
    required this.gameOver,
  });
}

class SudokuController extends ChangeNotifier {
  final GameService _service = GameService();
  final PreferencesStore _prefs;
  late History _history;
  Coord? _selected;
  bool _notesMode = false;
  String _difficulty = 'easy';
  bool _difficultyLocked = false;
  Set<Coord> _lastConflicts = {};
  bool _lastSolved = false;
  String _statusText = 'Welcome.';
  String _styleName = 'Modern';
  String _contentMode = 'animals';
  String _animalStyle = 'cute';
  bool _gameOver = false;
  Set<Coord> _incorrectCells = {};
  Set<Coord> _solutionAddedCells = {};
  Set<Coord> _correctCells = {};
  Grid? _solutionGrid;
  Grid? _initialGrid;

  SudokuController({PreferencesStore? preferencesStore})
      : _prefs = preferencesStore ?? PreferencesStore() {
    _history = _service.initialHistory();
    start();
    _loadPreferences();
  }

  UiState get state => _buildState();

  void start() {
    final puzzle = puzzles.generatePuzzle(_difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _lastSolved = false;
    _difficultyLocked = false;
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _copyGrid(puzzle.grid);
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
    final res = _notesMode
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
    final res = _notesMode
        ? _service.clearNotes(_history, _selected!)
        : _service.clearCell(_history, _selected!);
    _applyResult(res);
    _lockDifficultyIfFirstPlayerChange(before, _history);
  }

  void onToggleNotesMode() {
    if (_gameOver) {
      return;
    }
    _notesMode = !_notesMode;
    _render(_notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onUndo() {
    if (_gameOver) {
      return;
    }
    final res = _service.undo(_history);
    _applyResult(res);
  }

  void onRedo() {
    if (_gameOver) {
      return;
    }
    final res = _service.redo(_history);
    _applyResult(res);
  }

  void onNewGame() {
    final puzzle = puzzles.generatePuzzle(_difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _lastSolved = false;
    _difficultyLocked = false;
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _copyGrid(puzzle.grid);
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
  }

  void onSetDifficulty(String difficulty) {
    final d = difficulty.trim().toLowerCase();
    if (!['easy', 'medium', 'hard'].contains(d)) {
      _render('Unknown difficulty: $difficulty');
      return;
    }
    if (_difficultyLocked) {
      _render('Finish or start a new game before changing difficulty');
      return;
    }
    _difficulty = d;
    _prefs.saveDifficulty(_difficulty);
    final puzzle = puzzles.generatePuzzle(_difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _lastSolved = false;
    _difficultyLocked = false;
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
    _initialGrid = _copyGrid(puzzle.grid);
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
  }

  void onStyleChanged(String styleName) {
    _styleName = styleName;
    _render('Style: $styleName');
    _prefs.saveStyleName(_styleName);
  }

  void onContentModeChanged(String mode) {
    _contentMode = (mode == 'animals') ? 'animals' : 'numbers';
    _render('Mode: ${_contentMode == 'animals' ? 'Animals' : 'Numbers'}');
    _prefs.saveContentMode(_contentMode);
  }

  void onAnimalStyleChanged(String style) {
    _animalStyle = style == 'cute' ? 'cute' : 'simple';
    _render('Animal style: $_animalStyle');
    _prefs.saveAnimalStyle(_animalStyle);
  }

  void onCheckSolution() {
    if (_gameOver) {
      return;
    }
    final base = _initialGrid ?? _gridFromBoard(_history.present.board);
    final solved = solveGrid(base);
    if (solved == null) {
      return;
    }
    final incorrect = <Coord>{};
    final added = <Coord>{};
    final correct = <Coord>{};
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final value = _history.present.board.cellAt(r, c).value;
        final solvedValue = solved[r][c];
        if (value != null && solvedValue != null && value != solvedValue) {
          incorrect.add(Coord(r, c));
        } else if (value != null && solvedValue != null && value == solvedValue) {
          final cell = _history.present.board.cellAt(r, c);
          if (!cell.given) {
            correct.add(Coord(r, c));
          }
        } else if (value == null && solvedValue != null) {
          added.add(Coord(r, c));
        }
      }
    }
    _incorrectCells = incorrect;
    _correctCells = correct;
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
    final base = _initialGrid ?? _gridFromBoard(_history.present.board);
    final solved = solveGrid(base);
    if (solved == null) {
      return;
    }
    final incorrect = <Coord>{};
    final added = <Coord>{};
    final correct = <Coord>{};
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final value = _history.present.board.cellAt(r, c).value;
        final solvedValue = solved[r][c];
        if (value != null && solvedValue != null && value != solvedValue) {
          incorrect.add(Coord(r, c));
        } else if (value != null && solvedValue != null && value == solvedValue) {
          final cell = _history.present.board.cellAt(r, c);
          if (!cell.given) {
            correct.add(Coord(r, c));
          }
        } else if (value == null && solvedValue != null) {
          added.add(Coord(r, c));
        }
      }
    }
    _incorrectCells = incorrect;
    _correctCells = correct;
    _solutionGrid = solved;
    _solutionAddedCells = added;
    _selected = null;
    _render('Solution');
  }

  Future<void> onSaveRequested(BuildContext context) async {
    final payload = _service.exportSave(_history);
    final jsonText = const JsonEncoder.withIndent('  ').convert(payload);
    await Clipboard.setData(ClipboardData(text: jsonText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save copied to clipboard.')),
      );
    }
  }

  Future<void> onLoadRequested(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Load Game'),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste save JSON here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Load'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(result);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Save file format not recognised.');
      }
      final res = _service.importSave(decoded);
      _selected = null;
      _lastConflicts = {};
      _lastSolved = false;
      _difficultyLocked = res.history.canUndo();
      _gameOver = false;
      _incorrectCells = {};
      _solutionAddedCells = {};
      _correctCells = {};
      _solutionGrid = null;
      _initialGrid = _extractInitialGrid(res.history);
      _applyResult(res, statusOverride: 'Game loaded.');
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load failed: $error')),
        );
      }
    }
  }

  void _lockDifficultyIfFirstPlayerChange(History before, History after) {
    if (_difficultyLocked) {
      return;
    }
    if (!before.canUndo() && after.canUndo()) {
      _difficultyLocked = true;
    }
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _history = res.history;
    _lastConflicts = res.conflicts;
    _lastSolved = res.solved;
    _render(statusOverride ?? res.message);
  }

  void _render(String status) {
    _statusText = status;
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
      statusText: _statusText,
      notesMode: _notesMode,
      canUndo: _history.canUndo(),
      canRedo: _history.canRedo(),
      solved: _lastSolved,
      difficulty: _difficulty,
      canChangeDifficulty: !_difficultyLocked,
      styleName: _styleName,
      contentMode: _contentMode,
      animalStyle: _animalStyle,
      selected: _selected,
      gameOver: _gameOver,
    );
  }

  Grid _gridFromBoard(Board board) {
    return List<List<Digit?>>.generate(
      9,
      (r) => List<Digit?>.generate(9, (c) => board.cellAt(r, c).value),
      growable: false,
    );
  }

  Grid _extractInitialGrid(History history) {
    if (history.past.isNotEmpty) {
      return _gridFromBoard(history.past.first.board);
    }
    return _gridFromBoard(history.present.board);
  }

  Grid _copyGrid(Grid grid) {
    return grid.map((row) => row.toList(growable: false)).toList(growable: false);
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefs.load();
    final animalStyle = prefs.animalStyle;
    final contentMode = prefs.contentMode;
    final styleName = prefs.styleName;
    final difficulty = prefs.difficulty;

    var changed = false;
    if (animalStyle == 'cute' || animalStyle == 'simple') {
      _animalStyle = animalStyle!;
      changed = true;
    }
    if (contentMode == 'animals' || contentMode == 'numbers') {
      _contentMode = contentMode!;
      changed = true;
    }
    if (styleName != null && styleName.isNotEmpty) {
      _styleName = styleName;
      changed = true;
    }
    if (difficulty != null && ['easy', 'medium', 'hard'].contains(difficulty)) {
      _difficulty = difficulty;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  // Preferences are saved via PreferencesStore.
}
