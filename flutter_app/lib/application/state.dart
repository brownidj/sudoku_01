import 'package:flutter_app/domain/types.dart';

class GameState {
  final Board board;

  const GameState({required this.board});
}

class History {
  final List<GameState> past;
  final GameState present;
  final List<GameState> future;

  const History({
    required this.past,
    required this.present,
    required this.future,
  });

  static History initial(GameState state) {
    return History(past: const [], present: state, future: const []);
  }

  bool canUndo() => past.isNotEmpty;

  bool canRedo() => future.isNotEmpty;

  History push(GameState newPresent) {
    if (newPresent.board == present.board) {
      return this;
    }
    return History(
      past: [...past, present],
      present: newPresent,
      future: const [],
    );
  }

  History undo() {
    if (!canUndo()) {
      return this;
    }
    final prev = past.last;
    final newPast = past.sublist(0, past.length - 1);
    final newFuture = [present, ...future];
    return History(past: newPast, present: prev, future: newFuture);
  }

  History redo() {
    if (!canRedo()) {
      return this;
    }
    final next = future.first;
    final newFuture = future.sublist(1);
    final newPast = [...past, present];
    return History(past: newPast, present: next, future: newFuture);
  }
}

GameState newGameStateEmpty() {
  return GameState(board: Board.empty());
}
