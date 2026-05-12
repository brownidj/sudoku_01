import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/progress_metrics_service.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('recordPuzzleCompletion tracks days played and streak across dates', () async {
    final prefs = FakePreferencesStore();
    final service = ProgressMetricsService(prefs);

    final day1 = DateTime(2026, 5, 10, 9);
    final day2 = DateTime(2026, 5, 11, 9);
    final day4 = DateTime(2026, 5, 13, 9);

    final first = await service.recordPuzzleCompletion(
      completedPuzzles: 1,
      difficulty: 'easy',
      solveDuration: const Duration(seconds: 95),
      playedAt: day1,
    );
    expect(first.daysPlayed, 1);
    expect(first.streak, 1);

    final second = await service.recordPuzzleCompletion(
      completedPuzzles: 2,
      difficulty: 'easy',
      solveDuration: const Duration(seconds: 90),
      playedAt: day2,
    );
    expect(second.daysPlayed, 2);
    expect(second.streak, 2);

    final third = await service.recordPuzzleCompletion(
      completedPuzzles: 3,
      difficulty: 'easy',
      solveDuration: const Duration(seconds: 85),
      playedAt: day4,
    );
    expect(third.daysPlayed, 3);
    expect(third.streak, 1);
  });

  test('recordPuzzleCompletion stores best solve time per difficulty', () async {
    final prefs = FakePreferencesStore();
    final service = ProgressMetricsService(prefs);

    await service.recordPuzzleCompletion(
      completedPuzzles: 1,
      difficulty: 'easy',
      solveDuration: const Duration(seconds: 120),
      playedAt: DateTime(2026, 5, 10, 9),
    );
    await service.recordPuzzleCompletion(
      completedPuzzles: 2,
      difficulty: 'easy',
      solveDuration: const Duration(seconds: 140),
      playedAt: DateTime(2026, 5, 10, 10),
    );
    final metrics = await service.recordPuzzleCompletion(
      completedPuzzles: 3,
      difficulty: 'medium',
      solveDuration: const Duration(seconds: 200),
      playedAt: DateTime(2026, 5, 11, 9),
    );

    expect(metrics.bestSolveTimeSecondsByDifficulty['easy'], 120);
    expect(metrics.bestSolveTimeSecondsByDifficulty['medium'], 200);
  });
}
