import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

class TopControls extends StatelessWidget {
  final UiState state;
  final VoidCallback onNewGame;
  final ValueChanged<String> onContentModeChanged;
  final ValueChanged<String> onSetDifficulty;
  final ValueChanged<String> onStyleChanged;

  const TopControls({
    super.key,
    required this.state,
    required this.onNewGame,
    required this.onContentModeChanged,
    required this.onSetDifficulty,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ToggleButtons(
                  isSelected: [state.contentMode == 'animals', state.contentMode == 'numbers'],
                  onPressed: (index) {
                    onContentModeChanged(index == 0 ? 'animals' : 'numbers');
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Animals'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Numbers'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onNewGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              DropdownButton<String>(
                value: state.difficulty,
                onChanged: state.canChangeDifficulty
                    ? (value) {
                        if (value != null) {
                          onSetDifficulty(value);
                        }
                      }
                    : null,
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Style'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: state.styleName,
                    onChanged: (value) {
                      if (value != null) {
                        onStyleChanged(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'Modern', child: Text('Modern')),
                      DropdownMenuItem(value: 'Classic', child: Text('Classic')),
                      DropdownMenuItem(value: 'High Contrast', child: Text('High Contrast')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
