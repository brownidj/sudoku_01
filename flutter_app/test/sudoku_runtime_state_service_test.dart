import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

void main() {
  test('givenCoords returns only given cells', () {
    final service = SudokuRuntimeStateService();
    final cells = List<List<Cell>>.generate(
      9,
      (_) => List<Cell>.generate(
        9,
        (_) => Cell(value: null, given: false, notes: {}),
        growable: false,
      ),
      growable: false,
    );
    cells[0][0] = Cell(value: 1, given: true, notes: {});
    cells[4][5] = Cell(value: 9, given: true, notes: {});
    cells[8][8] = Cell(value: 3, given: false, notes: {});
    final history = History.initial(GameState(board: Board(cells: cells)));

    expect(service.givenCoords(history), {
      const Coord(0, 0),
      const Coord(4, 5),
    });
  });

  test(
    'clearCorrectionPromptState preserves reverted cells when requested',
    () {
      final service = SudokuRuntimeStateService();
      final history = History.initial(GameState(board: Board.empty()));
      final runtime = SudokuRuntimeState(
        history: history,
        correctionState:
            CorrectionState.initial(
              difficulty: 'easy',
              history: history,
            ).copyWith(
              pendingPromptCoord: const Coord(1, 1),
              revertedCells: {const Coord(2, 2)},
            ),
      );

      service.clearCorrectionPromptState(runtime, clearRevertedCells: false);

      expect(runtime.correctionState.pendingPromptCoord, isNull);
      expect(runtime.correctionState.revertedCells, {const Coord(2, 2)});
    },
  );
}
