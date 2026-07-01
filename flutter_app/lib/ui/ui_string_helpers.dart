import 'package:flutter/widgets.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class UiStringHelpers {
  static List<String> launchHints(BuildContext context) => [
    UiStrings.l10n(context).launchHint1,
    UiStrings.l10n(context).launchHint2,
    UiStrings.l10n(context).launchHint3,
    UiStrings.l10n(context).launchHint4,
    UiStrings.l10n(context).launchHint5,
    UiStrings.l10n(context).launchHint6,
    UiStrings.l10n(context).launchHint7,
    UiStrings.l10n(context).launchHint8,
    UiStrings.l10n(context).launchHint9,
    UiStrings.l10n(context).launchHint10,
  ];

  static List<String> victoryCelebrationMessages(BuildContext context) => [
    UiStrings.l10n(context).victoryMessage1,
    UiStrings.l10n(context).victoryMessage2,
    UiStrings.l10n(context).victoryMessage3,
    UiStrings.l10n(context).victoryMessage4,
    UiStrings.l10n(context).victoryMessage5,
    UiStrings.l10n(context).victoryMessage6,
    UiStrings.l10n(context).victoryMessage7,
    UiStrings.l10n(context).victoryMessage8,
    UiStrings.l10n(context).victoryMessage9,
    UiStrings.l10n(context).victoryMessage10,
    UiStrings.l10n(context).victoryMessage11,
    UiStrings.l10n(context).victoryMessage12,
    UiStrings.l10n(context).victoryMessage13,
    UiStrings.l10n(context).victoryMessage14,
    UiStrings.l10n(context).victoryMessage15,
    UiStrings.l10n(context).victoryMessage16,
    UiStrings.l10n(context).victoryMessage17,
    UiStrings.l10n(context).victoryMessage18,
    UiStrings.l10n(context).victoryMessage19,
    UiStrings.l10n(context).victoryMessage20,
  ];

  static String progressSheetBody(
    BuildContext context, {
    required int completedPuzzles,
    required int daysPlayed,
    required int streak,
    required Map<String, int> bestSolveTimeSecondsByDifficulty,
  }) {
    final l10n = UiStrings.l10n(context);
    final lines = <String>[
      l10n.progressCompletedPuzzles(completedPuzzles),
      l10n.progressDaysPlayed(daysPlayed),
      l10n.progressStreak(streak),
      l10n.progressBestSolveTimesTitle,
      l10n.progressBestSolveTimeRow(
        UiStrings.difficultyEasy(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['easy']),
      ),
      l10n.progressBestSolveTimeRow(
        UiStrings.difficultyMedium(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['medium']),
      ),
      l10n.progressBestSolveTimeRow(
        UiStrings.difficultyHard(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['hard']),
      ),
      l10n.progressBestSolveTimeRow(
        UiStrings.difficultyVeryHard(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['very_hard']),
      ),
    ];
    return lines.join('\n');
  }

  static String progressSheetBodyFree(
    BuildContext context, {
    required int completedPuzzles,
  }) {
    return UiStrings.l10n(context).progressCompletedPuzzles(completedPuzzles);
  }

  static String _formatDuration(BuildContext context, int? seconds) {
    if (seconds == null) {
      return UiStrings.l10n(context).progressBestSolveTimeMissing;
    }
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
