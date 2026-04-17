import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class TopControls extends StatelessWidget {
  final UiState state;
  final VoidCallback onNewGame;
  final ValueChanged<String> onContentModeChanged;
  final ValueChanged<String> onStyleChanged;

  const TopControls({
    super.key,
    required this.state,
    required this.onNewGame,
    required this.onContentModeChanged,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<String>(
                  value: switch (state.contentMode) {
                    'numbers' => 'numbers',
                    _ => 'animals',
                  },
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onContentModeChanged(value);
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'animals',
                      child: Text('Animals'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'numbers',
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
        ],
      ),
    );
  }
}
