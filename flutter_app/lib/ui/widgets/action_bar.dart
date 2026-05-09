import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/widgets/long_press_tooltip.dart';

class ActionBar extends StatelessWidget {
  static const String undoTooltip =
      'Use Undo to step back through the selections you made previously. '
      'Undo clears each previous selection, one at a time. '
      'You can also do this if you run out of Corrections';

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
    const controlWidth = 52.0;
    const controlHeight = 52.0;
    const notesWidth = 100.0;
    const notesHeight = 65.0;

    final compactStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(controlWidth, controlHeight),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: const TextStyle(fontSize: 13),
    );
    final animateNewGameDice = state.puzzleSolved || !state.canUndo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showNewGame)
            Tooltip(
              message: 'New Game',
              child: Semantics(
                label: 'New Game',
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
          OutlinedButton(
            style: compactStyle,
            onPressed: onClear,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 6),
          LongPressTooltip(
            message: undoTooltip,
            child: OutlinedButton(
              style: compactStyle,
              onPressed: state.canUndo ? onUndo : null,
              child: const Text('Undo'),
            ),
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
