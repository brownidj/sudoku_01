import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state_service.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

void main() {
  test('active elapsed time caps a single idle window at sixty seconds', () {
    const service = SudokuRuntimeStateService();
    final start = DateTime(2026, 7, 3, 9);
    final runtime = SudokuRuntimeState(
      history: History.initial(GameState(board: Board.empty())),
      correctionState: CorrectionState.initial(
        difficulty: 'easy',
        history: History.initial(GameState(board: Board.empty())),
      ),
      activeElapsedSeconds: 120,
      activeTimingStartedAt: start,
    );

    final elapsed = service.activeElapsedSeconds(
      runtime,
      now: start.add(const Duration(seconds: 90)),
    );

    expect(elapsed, 180);
  });

  test('registerActiveUse starts a new active timing window', () {
    const service = SudokuRuntimeStateService();
    final start = DateTime(2026, 7, 3, 9);
    final next = start.add(const Duration(seconds: 90));
    final runtime = SudokuRuntimeState(
      history: History.initial(GameState(board: Board.empty())),
      correctionState: CorrectionState.initial(
        difficulty: 'easy',
        history: History.initial(GameState(board: Board.empty())),
      ),
      activeElapsedSeconds: 120,
      activeTimingStartedAt: start,
    );

    service.registerActiveUse(runtime, now: next);

    expect(runtime.activeElapsedSeconds, 180);
    expect(runtime.activeTimingStartedAt, next);
  });

  test('pause and resume do not count background time', () {
    const service = SudokuRuntimeStateService();
    final start = DateTime(2026, 7, 3, 9);
    final pausedAt = start.add(const Duration(seconds: 20));
    final resumedAt = start.add(const Duration(minutes: 30));
    final runtime = SudokuRuntimeState(
      history: History.initial(GameState(board: Board.empty())),
      correctionState: CorrectionState.initial(
        difficulty: 'easy',
        history: History.initial(GameState(board: Board.empty())),
      ),
      activeTimingStartedAt: start,
    );

    service.pauseActiveTiming(runtime, now: pausedAt);
    service.resumeActiveTiming(runtime, now: resumedAt);

    expect(runtime.activeElapsedSeconds, 20);
    expect(runtime.activeTimingStartedAt, resumedAt);
  });
}
