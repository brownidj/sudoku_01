import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class SudokuNewGameConfirmationService {
  const SudokuNewGameConfirmationService();

  Future<void> confirmAndRun({
    required BuildContext context,
    required bool Function() isMounted,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UiStrings.dialogActionCancel(context)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(UiStrings.dialogActionStartNewGame(context)),
          ),
        ],
      ),
    );
    if (confirm != true || !isMounted()) {
      return;
    }
    onConfirm();
  }
}
