import 'package:flutter_app/app/preferences_store.dart';

class ProgressMetrics {
  final int completedPuzzles;
  final int daysPlayed;
  final int streak;
  final Map<String, int> bestSolveTimeSecondsByDifficulty;

  const ProgressMetrics({
    required this.completedPuzzles,
    required this.daysPlayed,
    required this.streak,
    required this.bestSolveTimeSecondsByDifficulty,
  });
}

class ProgressMetricsService {
  final PreferencesStore _preferencesStore;

  const ProgressMetricsService(this._preferencesStore);

  Future<ProgressMetrics> loadMetrics() async {
    final completedPuzzles = await _preferencesStore.loadCompletedPuzzles();
    final storedPlayedDates = await _preferencesStore.loadPlayedDates();
    final playedDates = storedPlayedDates.toSet().toList()..sort();
    final storedDaysPlayed = await _preferencesStore.loadDaysPlayed();
    final daysPlayed = playedDates.isNotEmpty ? playedDates.length : storedDaysPlayed;
    final streak = await _preferencesStore.loadCurrentStreak();
    final best = <String, int>{};
    for (final difficulty in const <String>['easy', 'medium', 'hard', 'very_hard']) {
      final seconds = await _preferencesStore.loadBestSolveTimeSeconds(difficulty);
      if (seconds != null && seconds > 0) {
        best[difficulty] = seconds;
      }
    }
    return ProgressMetrics(
      completedPuzzles: completedPuzzles,
      daysPlayed: daysPlayed,
      streak: streak,
      bestSolveTimeSecondsByDifficulty: best,
    );
  }

  Future<ProgressMetrics> recordPuzzleCompletion({
    required int completedPuzzles,
    required String difficulty,
    required Duration solveDuration,
    DateTime? playedAt,
  }) async {
    final now = playedAt ?? DateTime.now();
    final today = _dateKey(now);

    final existingDates = (await _preferencesStore.loadPlayedDates()).toSet();
    existingDates.add(today);
    final playedDates = existingDates.toList()..sort();
    final daysPlayed = playedDates.length;

    final previousDate = await _preferencesStore.loadLastPlayedDate();
    var streak = await _preferencesStore.loadCurrentStreak();
    if (previousDate == null || previousDate.isEmpty) {
      streak = 1;
    } else if (previousDate == today) {
      streak = streak == 0 ? 1 : streak;
    } else {
      final expectedPrevious = _dateKey(now.subtract(const Duration(days: 1)));
      streak = previousDate == expectedPrevious ? streak + 1 : 1;
    }

    final solveSeconds = solveDuration.inSeconds.clamp(1, 1 << 30);
    final best = <String, int>{};
    for (final level in const <String>['easy', 'medium', 'hard', 'very_hard']) {
      final value = await _preferencesStore.loadBestSolveTimeSeconds(level);
      if (value != null && value > 0) {
        best[level] = value;
      }
    }
    final currentBest = best[difficulty];
    if (currentBest == null || solveSeconds < currentBest) {
      best[difficulty] = solveSeconds;
      await _preferencesStore.saveBestSolveTimeSeconds(difficulty, solveSeconds);
    }

    await _preferencesStore.saveCompletedPuzzles(completedPuzzles);
    await _preferencesStore.savePlayedDates(playedDates);
    await _preferencesStore.saveDaysPlayed(daysPlayed);
    await _preferencesStore.saveCurrentStreak(streak);
    await _preferencesStore.saveLastPlayedDate(today);

    return ProgressMetrics(
      completedPuzzles: completedPuzzles,
      daysPlayed: daysPlayed,
      streak: streak,
      bestSolveTimeSecondsByDifficulty: best,
    );
  }

  Future<ProgressMetrics> resetMetrics() async {
    await _preferencesStore.clearProgressMetrics();
    return const ProgressMetrics(
      completedPuzzles: 0,
      daysPlayed: 0,
      streak: 0,
      bestSolveTimeSecondsByDifficulty: <String, int>{},
    );
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
