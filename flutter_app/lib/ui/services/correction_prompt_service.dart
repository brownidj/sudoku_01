import 'package:flutter/material.dart';
import 'package:flutter_app/domain/types.dart';

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
          content: const Text(
            'This board is unsatisfiable from an earlier move. Use 1 correction?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Use correction'),
            ),
          ],
        );
      },
    );
    return useCorrection == true;
  }
}
