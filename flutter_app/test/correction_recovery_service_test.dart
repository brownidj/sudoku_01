import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/contradiction_service.dart';
import 'package:flutter_app/app/correction_recovery_service.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

History _historyWithDeadCell() {
  final cells = List<List<Cell>>.generate(
    9,
    (_) => List<Cell>.generate(
      9,
      (_) => Cell(value: null, given: false, notes: {}),
      growable: false,
    ),
    growable: false,
  );

  cells[0][1] = Cell(value: 1, given: true, notes: {});
  cells[1][0] = Cell(value: 2, given: false, notes: {});
  cells[1][1] = Cell(value: 3, given: false, notes: {});
  cells[0][2] = Cell(value: 4, given: false, notes: {});
  cells[0][3] = Cell(value: 5, given: false, notes: {});
  cells[0][4] = Cell(value: 6, given: false, notes: {});
  cells[0][5] = Cell(value: 7, given: false, notes: {});
  cells[0][6] = Cell(value: 8, given: false, notes: {});
  cells[0][7] = Cell(value: 9, given: false, notes: {});

  final board = Board(cells: cells);
  return History(
    past: [History.initial(GameState(board: Board.empty())).present],
    present: GameState(board: board),
    future: const [],
  );
}

void main() {
  test('queuePromptForSelection targets dead cells only', () {
    final service = CorrectionRecoveryService(
      contradictionService: const ContradictionService(),
    );
    final history = _historyWithDeadCell();
    final state = CorrectionState.initial(difficulty: 'easy', history: history);

    final queued = service.queuePromptForSelection(
      history: history,
      correctionState: state,
      coord: const Coord(0, 0),
    );

    expect(queued.pendingPromptCoord, const Coord(0, 0));
  });

  test('confirmCorrection clears a blocker and decrements tokens', () {
    final service = CorrectionRecoveryService(
      contradictionService: const ContradictionService(),
    );
    final history = _historyWithDeadCell();
    final state = CorrectionState.initial(
      difficulty: 'easy',
      history: history,
    ).copyWith(pendingPromptCoord: const Coord(0, 0));

    final result = service.confirmCorrection(
      history: history,
      correctionState: state,
      initialGrid: null,
    );

    expect(result.status, startsWith('Correction used. Cleared '));
    expect(result.correctedTiles, greaterThan(0));
    expect(result.correctionState.tokensLeft, 2);
    expect(result.correctionState.pendingPromptCoord, isNull);
    expect(
      result.history.present.board.cellAtCoord(const Coord(1, 0)).value,
      isNull,
    );
  });
}
