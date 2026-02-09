import 'package:flutter_app/application/persistence.dart' as persistence;
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/ops.dart' as ops;
import 'package:flutter_app/domain/rules.dart' as rules;
import 'package:flutter_app/domain/types.dart';

class GameService {
  History initialHistory() {
    return History.initial(GameState(board: Board.empty()));
  }

  MoveResult newGameEmpty() {
    final history = initialHistory();
    return MoveResult(
      history: history,
      conflicts: const {},
      message: 'New game.',
      solved: false,
    );
  }

  MoveResult newGameFromGrid(Grid grid) {
    final board = Board.fromGrid(grid, givens: true);
    final history = History.initial(GameState(board: board));
    return _result(history, null, 'New game started.');
  }

  MoveResult newGame({String puzzleId = 'starter'}) {
    final puzzle = puzzles.getPuzzle(puzzleId);
    return newGameFromGrid(puzzle.grid);
  }

  Map<String, dynamic> exportSave(History history) {
    return persistence.serializeHistory(history);
  }

  MoveResult importSave(Map<String, dynamic> data) {
    final history = persistence.deserializeHistory(data);
    return _result(history, null, 'Game loaded.');
  }

  MoveResult placeDigit(History history, Coord coord, Digit digit) {
    final before = history.present.board;
    final legal = rules.isLegalPlacement(before, coord, digit);
    final after = ops.setValue(before, coord, digit);
    if (after == before) {
      return _result(history, coord, 'No change.');
    }
    final newHistory = history.push(GameState(board: after));
    final message = legal ? '' : 'Conflict.';
    return _result(newHistory, coord, message);
  }

  MoveResult clearCell(History history, Coord coord) {
    final before = history.present.board;
    final after = ops.clearValue(before, coord);
    if (after == before) {
      return _result(history, coord, 'No change.');
    }
    final newHistory = history.push(GameState(board: after));
    return _result(newHistory, coord, 'Cell cleared.');
  }

  MoveResult toggleNote(History history, Coord coord, Digit digit) {
    final before = history.present.board;
    final after = ops.toggleNote(before, coord, digit);
    if (after == before) {
      return _result(history, null, 'No change.');
    }
    final newHistory = history.push(GameState(board: after));
    return _result(newHistory, null, 'Note toggled.');
  }

  MoveResult undo(History history) {
    if (!history.canUndo()) {
      return _result(history, null, 'Nothing to undo.');
    }
    final newHistory = history.undo();
    return _result(newHistory, null, 'Undone.');
  }

  MoveResult redo(History history) {
    if (!history.canRedo()) {
      return _result(history, null, 'Nothing to redo.');
    }
    final newHistory = history.redo();
    return _result(newHistory, null, 'Redone.');
  }

  MoveResult _result(History history, Coord? coord, String message) {
    final board = history.present.board;
    Set<Coord> conflicts;
    if (coord == null) {
      conflicts = {};
    } else {
      final other = rules.conflictsForCell(board, coord);
      if (other.isNotEmpty) {
        other.add(coord);
      }
      conflicts = other;
    }
    final solved = rules.isSolved(board);
    if (solved) {
      message = 'Solved.';
    }
    return MoveResult(
      history: history,
      conflicts: conflicts,
      message: message,
      solved: solved,
    );
  }
}
