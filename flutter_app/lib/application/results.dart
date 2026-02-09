import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class MoveResult {
  final History history;
  final Set<Coord> conflicts;
  final String message;
  final bool solved;

  const MoveResult({
    required this.history,
    required this.conflicts,
    required this.message,
    required this.solved,
  });
}
