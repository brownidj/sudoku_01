import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';

class SudokuDrawer extends StatelessWidget {
  final UiState state;
  final ValueChanged<String> onAnimalStyleChanged;
  final ValueChanged<String> onStyleChanged;
  final bool audioEnabled;
  final ValueChanged<bool>? onAudioEnabledChanged;
  final ValueChanged<String>? onPremiumFeatureSelected;
  final VoidCallback? onUnlockPremiumSelected;
  final VoidCallback? onRestorePurchasesSelected;
  final VoidCallback? onLoadCorrectionScenario;
  final VoidCallback? onLoadExhaustedCorrectionScenario;
  final VoidCallback? onResetEntitlementToFreeSelected;
  final bool showDebugTools;

  const SudokuDrawer({
    super.key,
    required this.state,
    required this.onAnimalStyleChanged,
    required this.onStyleChanged,
    this.audioEnabled = true,
    this.onAudioEnabledChanged,
    this.onPremiumFeatureSelected,
    this.onUnlockPremiumSelected,
    this.onRestorePurchasesSelected,
    this.onLoadCorrectionScenario,
    this.onLoadExhaustedCorrectionScenario,
    this.onResetEntitlementToFreeSelected,
    this.showDebugTools = AppDebug.enabled,
  });

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Animals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Cute'),
              value: 'cute',
              groupValue: state.animalStyle,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('Simple'),
              value: 'simple',
              groupValue: state.animalStyle,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            const Divider(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Puzzle Style',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Modern'),
              value: 'Modern',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('Classic'),
              value: 'Classic',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('High Contrast'),
              value: 'High Contrast',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            const Divider(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Audio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(audioEnabled ? 'On' : 'Off'),
                  Radio<bool?>(
                    value: true,
                    groupValue: audioEnabled ? true : null,
                    toggleable: true,
                    visualDensity: VisualDensity.compact,
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
              key: const ValueKey<String>('drawer-premium-status'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('Version'),
              trailing: Text(
                state.premiumActive ? 'Full' : 'Free',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!state.premiumActive) ...[
              ListTile(
                key: const ValueKey<String>('drawer-locked-progress-tracker'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Progress Tracker 🔒'),
                subtitle: const Text('Track completed puzzles and milestones.'),
                onTap: onPremiumFeatureSelected == null
                    ? null
                    : () => onPremiumFeatureSelected!('progress_tracker'),
              ),
              ListTile(
                key: const ValueKey<String>('drawer-locked-extra-themes'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Extra Themes 🔒'),
                subtitle: const Text('Unlock additional visual styles.'),
                onTap: onPremiumFeatureSelected == null
                    ? null
                    : () => onPremiumFeatureSelected!('extra_themes'),
              ),
              ListTile(
                key: const ValueKey<String>('drawer-locked-extra-sounds'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Sounds & Celebrations 🔒'),
                subtitle: const Text('Unlock extra sounds and celebrations.'),
                onTap: onPremiumFeatureSelected == null
                    ? null
                    : () => onPremiumFeatureSelected!(
                        'extra_sounds_and_celebrations',
                      ),
              ),
              ListTile(
                key: const ValueKey<String>('drawer-unlock-premium'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Unlock Full Version'),
                onTap: onUnlockPremiumSelected,
              ),
            ],
            ListTile(
              key: const ValueKey<String>('drawer-restore-purchases'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.restore),
              title: const Text('Restore Purchases'),
              onTap: onRestorePurchasesSelected,
            ),
            if (showDebugTools &&
                (onLoadCorrectionScenario != null ||
                    onLoadExhaustedCorrectionScenario != null ||
                    onResetEntitlementToFreeSelected != null)) ...[
              const Divider(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Debug',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
              if (onResetEntitlementToFreeSelected != null)
                ListTile(
                  key: const ValueKey<String>('drawer-reset-entitlement-free'),
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset Full Version (Debug)'),
                  subtitle: const Text(
                    'Sets local entitlement to Free for purchase retesting.',
                  ),
                  onTap: onResetEntitlementToFreeSelected,
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
