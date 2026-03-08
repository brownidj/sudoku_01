import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class BoardEditOutcome {
  final MoveResult? result;
  final String? statusMessage;
  final bool lockDifficulty;
  final bool lockPuzzleMode;

  const BoardEditOutcome({
    required this.result,
    required this.statusMessage,
    required this.lockDifficulty,
    required this.lockPuzzleMode,
  });
}

class BoardEditCoordinator {
  final GameService _gameService;

  const BoardEditCoordinator(this._gameService);

  BoardEditOutcome onDigitPressed({
    required bool gameOver,
    required Coord? selected,
    required bool notesMode,
    required History history,
    required Digit digit,
    required bool canChangeDifficulty,
    required bool canChangePuzzleMode,
  }) {
    if (gameOver) {
      return const BoardEditOutcome(
        result: null,
        statusMessage: null,
        lockDifficulty: false,
        lockPuzzleMode: false,
      );
    }
    if (selected == null) {
      return const BoardEditOutcome(
        result: null,
        statusMessage: 'Select a cell',
        lockDifficulty: false,
        lockPuzzleMode: false,
      );
    }

    final before = history;
    final result = notesMode
        ? _gameService.toggleNote(history, selected, digit)
        : _gameService.placeDigit(history, selected, digit);
    return _withLocks(
      before: before,
      after: result.history,
      result: result,
      canChangeDifficulty: canChangeDifficulty,
      canChangePuzzleMode: canChangePuzzleMode,
    );
  }

  BoardEditOutcome onPlaceDigit({
    required bool gameOver,
    required Coord? selected,
    required History history,
    required Digit digit,
    required bool canChangeDifficulty,
    required bool canChangePuzzleMode,
  }) {
    if (gameOver || selected == null) {
      return const BoardEditOutcome(
        result: null,
        statusMessage: null,
        lockDifficulty: false,
        lockPuzzleMode: false,
      );
    }

    final before = history;
    final result = _gameService.placeDigit(history, selected, digit);
    return _withLocks(
      before: before,
      after: result.history,
      result: result,
      canChangeDifficulty: canChangeDifficulty,
      canChangePuzzleMode: canChangePuzzleMode,
    );
  }

  BoardEditOutcome onClearPressed({
    required bool gameOver,
    required Coord? selected,
    required bool notesMode,
    required History history,
    required bool canChangeDifficulty,
    required bool canChangePuzzleMode,
  }) {
    if (gameOver) {
      return const BoardEditOutcome(
        result: null,
        statusMessage: null,
        lockDifficulty: false,
        lockPuzzleMode: false,
      );
    }
    if (selected == null) {
      return const BoardEditOutcome(
        result: null,
        statusMessage: 'Select a cell',
        lockDifficulty: false,
        lockPuzzleMode: false,
      );
    }

    final before = history;
    final result = notesMode
        ? _gameService.clearNotes(history, selected)
        : _gameService.clearCell(history, selected);
    return _withLocks(
      before: before,
      after: result.history,
      result: result,
      canChangeDifficulty: canChangeDifficulty,
      canChangePuzzleMode: canChangePuzzleMode,
    );
  }

  BoardEditOutcome _withLocks({
    required History before,
    required History after,
    required MoveResult result,
    required bool canChangeDifficulty,
    required bool canChangePuzzleMode,
  }) {
    final firstPlayerChange = !before.canUndo() && after.canUndo();
    return BoardEditOutcome(
      result: result,
      statusMessage: null,
      lockDifficulty: canChangeDifficulty && firstPlayerChange,
      lockPuzzleMode: canChangePuzzleMode && firstPlayerChange,
    );
  }
}
