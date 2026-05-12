import 'package:flutter/material.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class CorrectionPromptService {
  Coord? _lastPromptCoord;

  bool shouldSchedule(Coord? promptCoord) {
    if (promptCoord == null) {
      _lastPromptCoord = null;
      return false;
    }
    if (_lastPromptCoord == promptCoord) {
      return false;
    }
    _lastPromptCoord = promptCoord;
    return true;
  }

  Future<bool> showPrompt(BuildContext context) async {
    final useCorrection = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(UiStrings.correctionPromptMessage(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(UiStrings.dialogActionCancel(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(UiStrings.dialogActionUseCorrection(context)),
            ),
          ],
        );
      },
    );
    return useCorrection == true;
  }
}
