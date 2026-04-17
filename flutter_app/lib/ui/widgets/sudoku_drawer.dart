import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';

class SudokuDrawer extends StatelessWidget {
  final UiState state;
  final ValueChanged<String> onAnimalStyleChanged;
  final ValueChanged<String> onStyleChanged;
  final bool audioEnabled;
  final ValueChanged<bool>? onAudioEnabledChanged;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onLoadCorrectionScenario;
  final VoidCallback? onLoadExhaustedCorrectionScenario;
  final bool showDebugTools;

  const SudokuDrawer({
    super.key,
    required this.state,
    required this.onAnimalStyleChanged,
    required this.onStyleChanged,
    this.audioEnabled = true,
    this.onAudioEnabledChanged,
    this.onHelpPressed,
    this.onLoadCorrectionScenario,
    this.onLoadExhaustedCorrectionScenario,
    this.showDebugTools = AppDebug.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final sectionStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final optionStyle = Theme.of(context).textTheme.bodyLarge;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ZuDoKu+',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Animals', style: sectionStyle),
            ),
            RadioListTile<String>(
              title: Text('Cute', style: optionStyle),
              value: 'cute',
              groupValue: state.animalStyle,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            RadioListTile<String>(
              title: Text('Simple', style: optionStyle),
              value: 'simple',
              groupValue: state.animalStyle,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            const Divider(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Puzzle Style', style: sectionStyle),
            ),
            RadioListTile<String>(
              title: Text('Modern', style: optionStyle),
              value: 'Modern',
              groupValue: state.styleName,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: Text('Classic', style: optionStyle),
              value: 'Classic',
              groupValue: state.styleName,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: Text('High Contrast', style: optionStyle),
              value: 'High Contrast',
              groupValue: state.styleName,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            const Divider(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text('Audio', style: sectionStyle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(audioEnabled ? 'On' : 'Off'),
                  Radio<bool?>(
                    value: true,
                    groupValue: audioEnabled ? true : null,
                    toggleable: true,
                    onChanged: _handleAudioChanged,
                  ),
                ],
              ),
              onTap: onAudioEnabledChanged == null
                  ? null
                  : () => onAudioEnabledChanged!(!audioEnabled),
            ),
            const Divider(height: 16),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: onHelpPressed,
            ),
            if (showDebugTools &&
                (onLoadCorrectionScenario != null ||
                    onLoadExhaustedCorrectionScenario != null)) ...[
              const Divider(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Debug', style: sectionStyle),
              ),
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: const Text('Load Correction Scenario'),
                subtitle: const Text(
                  'Temporary control for assisted-recovery testing.',
                ),
                onTap: onLoadCorrectionScenario,
              ),
              if (onLoadExhaustedCorrectionScenario != null)
                ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: const Text('Load Exhausted Correction Scenario'),
                  subtitle: const Text(
                    'Temporary control for undo-only recovery testing.',
                  ),
                  onTap: onLoadExhaustedCorrectionScenario,
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAnimalStyleChanged(String? value) {
    if (value == null) {
      return;
    }
    onAnimalStyleChanged(value);
  }

  void _handleStyleChanged(String? value) {
    if (value == null) {
      return;
    }
    onStyleChanged(value);
  }

  void _handleAudioChanged(bool? enabled) {
    if (onAudioEnabledChanged == null) {
      return;
    }
    onAudioEnabledChanged!(enabled == true);
  }
}
