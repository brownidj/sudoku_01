import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/ui_strings.dart';

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
    final showConfigLock = !state.canChangeDifficulty;
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
                    'butterflies' => 'butterflies',
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
                  items: [
                    DropdownMenuItem<String>(
                      value: 'animals',
                      child: Text(UiStrings.contentModeAnimals(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'instruments',
                      child: Text(UiStrings.contentModeInstruments(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'butterflies',
                      child: Text(UiStrings.contentModeButterflies(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'old_opera',
                      child: Text(UiStrings.contentModeOpera(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'numbers',
                      child: Text(UiStrings.contentModeNumbers(context)),
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
                        label: Text(UiStrings.topControlsProgress(context)),
                      )
                    : ActionChip(
                        key: const ValueKey<String>('top-controls-help-chip'),
                        onPressed: onHelpPressed,
                        label: Text(UiStrings.topControlsHelp(context)),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
