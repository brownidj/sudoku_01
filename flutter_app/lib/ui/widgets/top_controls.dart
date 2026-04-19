import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class TopControls extends StatelessWidget {
  final UiState state;
  final VoidCallback onNewGame;
  final ValueChanged<String> onContentModeChanged;
  final VoidCallback onConfigurationLockTapped;
  final VoidCallback onConfigurationLockDoubleTapped;
  final ValueChanged<String> onStyleChanged;

  const TopControls({
    super.key,
    required this.state,
    required this.onNewGame,
    required this.onContentModeChanged,
    required this.onConfigurationLockTapped,
    required this.onConfigurationLockDoubleTapped,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showConfigLock =
        !state.canChangeDifficulty || !state.canChangePuzzleMode;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                height: 48,
                child: DropdownButton<String>(
                  value: switch (state.contentMode) {
                    'animals' => 'animals',
                    'instruments' => 'instruments',
                    'numbers' => 'numbers',
                    _ => 'animals',
                  },
                  iconSize: 20,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onContentModeChanged(value);
                  },
                  style: Theme.of(context).textTheme.titleSmall,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'animals',
                      child: Text('Animals'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'instruments',
                      child: Text('Instruments'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'numbers',
                      child: Text('Numbers'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: showConfigLock
                    ? Center(
                        child: Material(
                          color: colorScheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                          child: InkWell(
                            key: const ValueKey<String>(
                              'top-controls-config-lock-indicator',
                            ),
                            customBorder: const CircleBorder(),
                            onTap: onConfigurationLockTapped,
                            onDoubleTap: onConfigurationLockDoubleTapped,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.lock,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ActionChip(
                  onPressed: onNewGame,
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
