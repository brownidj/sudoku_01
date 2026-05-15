import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

Future<void> showProgressSheetModal({
  required BuildContext context,
  required bool showExtendedMetrics,
  required int completedPuzzles,
  required int daysPlayed,
  required int streak,
  required Map<String, int> bestSolveTimeSecondsByDifficulty,
  required Future<void> Function() onResetProgressMetrics,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UiStrings.progressSheetTitle(sheetContext),
                  style: Theme.of(sheetContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  showExtendedMetrics
                      ? UiStrings.progressSheetBody(
                          sheetContext,
                          completedPuzzles: completedPuzzles,
                          daysPlayed: daysPlayed,
                          streak: streak,
                          bestSolveTimeSecondsByDifficulty:
                              bestSolveTimeSecondsByDifficulty,
                        )
                      : UiStrings.progressSheetBodyFree(
                          sheetContext,
                          completedPuzzles: completedPuzzles,
                        ),
                  style: Theme.of(sheetContext).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE4EC),
                      ),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: sheetContext,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: Text(
                                UiStrings.progressResetDialogTitle(
                                  dialogContext,
                                ),
                              ),
                              content: Text(
                                UiStrings.progressResetDialogMessage(
                                  dialogContext,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: Text(
                                    UiStrings.dialogActionCancel(dialogContext),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: Text(
                                    UiStrings.dialogActionOk(dialogContext),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed != true) {
                          return;
                        }
                        await onResetProgressMetrics();
                        if (!sheetContext.mounted) {
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(UiStrings.progressResetAction(sheetContext)),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(UiStrings.infoSheetDismiss(sheetContext)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
