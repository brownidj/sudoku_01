import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';

class LongPressTooltip extends StatelessWidget {
  final String? title;
  final String message;
  final Widget child;

  const LongPressTooltip({
    super.key,
    this.title,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () =>
          showInfoSheet(context: context, title: title, message: message),
      child: child,
    );
  }
}
