import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_app/ui/ui_strings.dart';

Future<void> showSudokuHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(UiStrings.helpTitle(context)),
        content: MarkdownBody(data: UiStrings.helpBody(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(UiStrings.helpDismiss(context)),
          ),
        ],
      );
    },
  );
}
