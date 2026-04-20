import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/widgets/long_press_tooltip.dart';

class SudokuBoardMetadataRow extends StatelessWidget {
  final UiState state;
  final String hintsTooltipMessage;
  final String correctionsTooltipMessage;
  final ValueChanged<String>? onPuzzleModeChanged;
  final ValueChanged<String>? onDifficultyChanged;

  const SudokuBoardMetadataRow({
    super.key,
    required this.state,
    required this.hintsTooltipMessage,
    required this.correctionsTooltipMessage,
    required this.onPuzzleModeChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _MetadataDropdown(
              tooltipMessage:
                  'UNIQUE has one solution. MULTI may have more than one valid solution. '
                  'Choose the mode that supports your regular puzzle routine.',
              value: state.puzzleMode,
              dropdownKey: const ValueKey<String>('board-puzzle-mode-dropdown'),
              enabled: state.canChangePuzzleMode,
              items: const [
                DropdownMenuItem<String>(
                  value: 'unique',
                  child: Text('UNIQUE'),
                ),
                DropdownMenuItem<String>(value: 'multi', child: Text('MULTI')),
              ],
              onChanged: onPuzzleModeChanged,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(-8, 0),
              child: _ManualTooltipLabel(
                label: 'Hints: ${state.conflictHintsLeft}',
                tooltipMessage: hintsTooltipMessage,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(-20, 0),
              child: _ManualTooltipLabel(
                label: 'Corrections: ${state.correctionsLeft}',
                tooltipMessage: correctionsTooltipMessage,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: _MetadataDropdown(
                tooltipMessage:
                    'Choose the challenge level that feels right for steady daily progress.',
                value: state.difficulty,
                dropdownKey: const ValueKey<String>('board-difficulty-dropdown'),
                enabled: state.canChangeDifficulty,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'easy',
                    child: Text('EASY'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'medium',
                    child: Text('A BIT HARDER'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'hard',
                    child: Text('MUCH HARDER'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'very_hard',
                    child: Text('NIGH IMPOSSIBLE'),
                  ),
                ],
                onChanged: onDifficultyChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataDropdown extends StatelessWidget {
  final String tooltipMessage;
  final String value;
  final Key dropdownKey;
  final bool enabled;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String>? onChanged;

  const _MetadataDropdown({
    required this.tooltipMessage,
    required this.value,
    required this.dropdownKey,
    required this.enabled,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownColor = enabled
        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.72)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
    return LongPressTooltip(
      message: tooltipMessage,
      child: DropdownButtonHideUnderline(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            height: 40,
            child: DropdownButton<String>(
              key: dropdownKey,
              value: value,
              isDense: true,
              itemHeight: 48,
              icon: Icon(Icons.arrow_drop_down, size: 20, color: dropdownColor),
              padding: EdgeInsets.zero,
              onChanged: !enabled
                  ? null
                  : (nextValue) {
                      if (nextValue == null) {
                        return;
                      }
                      onChanged?.call(nextValue);
                    },
              items: items,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: dropdownColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualTooltipLabel extends StatelessWidget {
  final String label;
  final String tooltipMessage;

  const _ManualTooltipLabel({
    required this.label,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: LongPressTooltip(
        message: tooltipMessage,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }
}
