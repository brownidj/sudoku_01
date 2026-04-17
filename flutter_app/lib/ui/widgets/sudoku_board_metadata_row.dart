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
            child: _ManualTooltipLabel(
              label: 'Hints: ${state.conflictHintsLeft}',
              tooltipMessage: hintsTooltipMessage,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _ManualTooltipLabel(
              label: 'Corrections: ${state.correctionsLeft}',
              tooltipMessage: correctionsTooltipMessage,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _MetadataDropdown(
              tooltipMessage:
                  'Choose the challenge level that feels right for steady daily progress.',
              value: state.difficulty,
              dropdownKey: const ValueKey<String>('board-difficulty-dropdown'),
              items: const [
                DropdownMenuItem<String>(value: 'easy', child: Text('EASY')),
                DropdownMenuItem<String>(
                  value: 'medium',
                  child: Text('MEDIUM'),
                ),
                DropdownMenuItem<String>(value: 'hard', child: Text('HARD')),
              ],
              onChanged: onDifficultyChanged,
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
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String>? onChanged;

  const _MetadataDropdown({
    required this.tooltipMessage,
    required this.value,
    required this.dropdownKey,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              isDense: false,
              itemHeight: 48,
              icon: const Icon(Icons.expand_more, size: 18),
              onChanged: (nextValue) {
                if (nextValue == null) {
                  return;
                }
                onChanged?.call(nextValue);
              },
              items: items,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.72),
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
