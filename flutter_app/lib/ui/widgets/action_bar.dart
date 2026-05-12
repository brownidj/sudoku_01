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
    final animateNewGameDice = state.puzzleSolved || !state.canUndo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showNewGame)
            Tooltip(
              message: UiStrings.tooltipNewGame(context),
              child: Semantics(
                label: UiStrings.actionNewGame(context),
                key: const ValueKey<String>('content-new-game-chip'),
                button: true,
                child: Transform.translate(
                  offset: const Offset(6, -6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onNewGamePressed,
                    child: SizedBox(
                      width: animateNewGameDice ? 52 : 44,
                      height: animateNewGameDice ? 52 : 44,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          animateNewGameDice
                              ? 'assets/images/icons/dice-roll.gif'
                              : 'assets/images/icons/dice-roll-still.png',
                          width: animateNewGameDice ? 52 : 44,
                          height: animateNewGameDice ? 52 : 44,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showNewGame) const SizedBox(width: 48),
          LongPressTooltip(
            message: UiStrings.tooltipClear(context),
            child: OutlinedButton(
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
