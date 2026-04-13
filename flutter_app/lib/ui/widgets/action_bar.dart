import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class ActionBar extends StatelessWidget {
  static const String undoTooltip =
      'Use Undo to step back through the selections you made previously. '
      'Undo clears each previous selection, one at a time. '
      'You can also do this if you run out of Corrections';
  static const String solutionTooltip =
      'First press stops the game and shows you what you got '
      'correct/incorrect. Second press shows you the complete solution.';

  final UiState state;
  final VoidCallback onUndo;
  final VoidCallback onToggleNotesMode;
  final VoidCallback onClear;
  final VoidCallback onCheckOrSolution;

  const ActionBar({
    super.key,
    required this.state,
    required this.onUndo,
    required this.onToggleNotesMode,
    required this.onClear,
    required this.onCheckOrSolution,
  });

  @override
  Widget build(BuildContext context) {
    const controlWidth = 44.0;
    const controlHeight = 34.0;
    const notesWidth = controlWidth * 2.25;
    const notesHeight = controlHeight * 1.5;

    final compactStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: const Size(controlWidth, controlHeight),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      textStyle: const TextStyle(fontSize: 13),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Tooltip(
            message: solutionTooltip,
            child: OutlinedButton(
              style: compactStyle,
              onPressed: onCheckOrSolution,
              child: const Text('Solution'),
            ),
          ),
          const SizedBox(width: 24),
          OutlinedButton(
            style: compactStyle,
            onPressed: onClear,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 6),
          Builder(
            builder: (context) {
              final tooltipKey = GlobalKey<TooltipState>();
              return Tooltip(
                key: tooltipKey,
                message: undoTooltip,
                triggerMode: TooltipTriggerMode.manual,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () =>
                      tooltipKey.currentState?.ensureTooltipVisible(),
                  child: OutlinedButton(
                    style: compactStyle,
                    onPressed: state.canUndo ? onUndo : null,
                    child: const Text('Undo'),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          OutlinedButton(
            style: compactStyle.copyWith(
              fixedSize: const WidgetStatePropertyAll(
                Size(notesWidth, notesHeight),
              ),
              minimumSize: const WidgetStatePropertyAll(
                Size(notesWidth, notesHeight),
              ),
              backgroundColor: WidgetStatePropertyAll(
                state.notesMode
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : null,
              ),
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: state.notesMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            onPressed: onToggleNotesMode,
            child: Text(
              'Notes',
              style: TextStyle(
                fontWeight: state.notesMode
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
