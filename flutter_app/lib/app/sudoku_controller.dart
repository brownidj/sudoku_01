import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class CellVm {
  final Coord coord;
  final Digit? value;
  final bool given;
  final List<Digit> notes;
  final bool selected;
  final bool conflicted;

  const CellVm({
    required this.coord,
    required this.value,
    required this.given,
    required this.notes,
    required this.selected,
    required this.conflicted,
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
  final Coord? selected;

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
    required this.selected,
  });
}

class SudokuController extends ChangeNotifier {
  final GameService _service = GameService();
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

  SudokuController() {
    _history = _service.initialHistory();
    start();
  }

  UiState get state => _buildState();

  void start() {
    final puzzle = puzzles.generatePuzzle(_difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _lastSolved = false;
    _difficultyLocked = false;
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
  }

  void onCellTapped(Coord coord) {
    final cell = _history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    _selected = coord;
    _render('Cell selected');
  }

  void onDigitPressed(Digit digit) {
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

  void onClearPressed() {
    if (_selected == null) {
      _render('Select a cell');
      return;
    }
    final before = _history;
    final res = _service.clearCell(_history, _selected!);
    _applyResult(res);
    _lockDifficultyIfFirstPlayerChange(before, _history);
  }

  void onToggleNotesMode() {
    _notesMode = !_notesMode;
    _render(_notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onUndo() {
    final res = _service.undo(_history);
    _applyResult(res);
  }

  void onRedo() {
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
    final puzzle = puzzles.generatePuzzle(_difficulty);
    final res = _service.newGameFromGrid(puzzle.grid);
    _selected = null;
    _lastConflicts = {};
    _lastSolved = false;
    _difficultyLocked = false;
    _applyResult(res, statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}');
  }

  void onStyleChanged(String styleName) {
    _styleName = styleName;
    _render('Style: $styleName');
  }

  void onContentModeChanged(String mode) {
    _contentMode = (mode == 'animals') ? 'animals' : 'numbers';
    _render('Mode: ${_contentMode == 'animals' ? 'Animals' : 'Numbers'}');
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
    for (var r = 0; r < 9; r += 1) {
      final row = <CellVm>[];
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        final cell = board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        row.add(
          CellVm(
            coord: coord,
            value: cell.value,
            given: cell.given,
            notes: notes,
            selected: coord == _selected,
            conflicted: _lastConflicts.contains(coord),
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
      selected: _selected,
    );
  }
}
