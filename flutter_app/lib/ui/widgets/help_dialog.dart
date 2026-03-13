import 'package:flutter/material.dart';

const String kSudokuHelpText =
    'Long-press "Corrections" on the board for a quick explanation. '
    'If an earlier move causes a tile to have no valid options, Corrections can '
    'automatically fix that dead end and let you keep playing.\n\n'
    'Use Undo to step back through the selections you made previously. '
    'Undo clears each previous selection, one at a time. '
    'You can also do this if you run out of Corrections';

Future<void> showSudokuHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Help'),
        content: const Text(kSudokuHelpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
