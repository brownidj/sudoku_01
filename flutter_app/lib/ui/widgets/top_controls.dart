import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class TopControls extends StatelessWidget {
  final UiState state;
  final VoidCallback onProgressPressed;
  final VoidCallback onHelpPressed;
  final ValueChanged<String> onContentModeChanged;
  final VoidCallback onConfigurationLockTapped;
  final VoidCallback onConfigurationLockDoubleTapped;
  final ValueChanged<String> onStyleChanged;

  const TopControls({
    super.key,
    required this.state,
    required this.onProgressPressed,
    required this.onHelpPressed,
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
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
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
                    'old_opera' => 'old_opera',
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
                      child: Text('Animals (easy)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'instruments',
                      child: Text('Instruments (harder)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'old_opera',
                      child: Text('Opera (even harder)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'numbers',
                      child: Text('Numbers (old-school)'),
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
                child: state.gameOver
                    ? ActionChip(
                        key: const ValueKey<String>(
                          'top-controls-progress-chip',
                        ),
                        onPressed: onProgressPressed,
                        label: const Text('How am I doing?'),
                      )
                    : ActionChip(
                        key: const ValueKey<String>('top-controls-help-chip'),
                        onPressed: onHelpPressed,
                        label: const Text('Help'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
