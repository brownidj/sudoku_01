import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const String kSudokuHelpText =
    'There are ***some things*** on the game screen that appear a bit mysterious.\n\n'
    'Try **holding your finger** for a couple of seconds on those to see an explanation.\n\n'
    'For example, **Corrections** shows the number of automatic corrections you have left. '
    'If an earlier move causes a tile to have no valid options, Corrections can '
    'automatically fix that dead end and let you keep playing.\n\n'
    'Use **Undo** to step back through the selections you made previously. '
    'Undo clears each previous selection, one at a time. '
    'You can also do this if you run out of Corrections.';

Future<void> showSudokuHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Help'),
        content: const MarkdownBody(data: kSudokuHelpText),
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
