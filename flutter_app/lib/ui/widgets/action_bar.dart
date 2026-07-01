import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/widgets/long_press_tooltip.dart';

class ActionBar extends StatelessWidget {
  final UiState state;
  final VoidCallback onUndo;
  final VoidCallback onToggleNotesMode;
  final VoidCallback onClear;
  final VoidCallback onCheckOrSolution;
  final VoidCallback? onNewGamePressed;
  final bool showNewGame;

  const ActionBar({
    super.key,
    required this.state,
    required this.onUndo,
    required this.onToggleNotesMode,
    required this.onClear,
    required this.onCheckOrSolution,
    this.onNewGamePressed,
    this.showNewGame = true,
  });

  @override
  Widget build(BuildContext context) {
    const narrowScreenBreakpoint = 390.0;
    const controlWidth = 52.0;
    const controlHeight = 52.0;
    const newGameWidth = 82.0;
    const newGameHeight = 65.0;
    const notesWidth = 100.0;
    const notesHeight = 65.0;
    final useIconOnlyLabels =
        MediaQuery.sizeOf(context).width <= narrowScreenBreakpoint;

    final compactStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(controlWidth, controlHeight),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: const TextStyle(fontSize: 13),
    );
    final actionLabelStyle = useIconOnlyLabels
        ? const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showNewGame)
            LongPressTooltip(
              message: UiStrings.tooltipNewGame(context),
              child: OutlinedButton(
                key: const ValueKey<String>('content-new-game-chip'),
                style: compactStyle.copyWith(
                  fixedSize: const WidgetStatePropertyAll(
                    Size(newGameWidth, newGameHeight),
                  ),
                  minimumSize: const WidgetStatePropertyAll(
                    Size(newGameWidth, newGameHeight),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(
                    Color(0xFFFFF3B0),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                ),
                onPressed: onNewGamePressed,
                child: Text(
                  UiStrings.actionNewGame(context),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          if (showNewGame) const SizedBox(width: 16),
          LongPressTooltip(
            message: UiStrings.tooltipClear(context),
            child: OutlinedButton(
              key: const ValueKey<String>('action-clear-button'),
              style: compactStyle,
              onPressed: onClear,
              child: Text(
                useIconOnlyLabels ? '⌫' : UiStrings.actionClear(context),
                style: actionLabelStyle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          LongPressTooltip(
            message: UiStrings.tooltipUndo(context),
            child: OutlinedButton(
              key: const ValueKey<String>('action-undo-button'),
              style: compactStyle,
              onPressed: state.canUndo ? onUndo : null,
              child: Text(
                useIconOnlyLabels ? '↶' : UiStrings.actionUndo(context),
                style: actionLabelStyle,
              ),
            ),
          ),
          const Spacer(),
          LongPressTooltip(
            message: UiStrings.tooltipNotes(context),
            child: OutlinedButton(
              key: const ValueKey<String>('action-notes-button'),
              style: compactStyle.copyWith(
                fixedSize: const WidgetStatePropertyAll(
                  Size(notesWidth, notesHeight),
                ),
                minimumSize: const WidgetStatePropertyAll(
                  Size(notesWidth, notesHeight),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  state.notesMode
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15)
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
                UiStrings.actionNotes(context),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
