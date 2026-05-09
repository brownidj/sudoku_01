import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class SudokuDrawerHeaderStyleSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final String selectedStyleName;
  final ValueChanged<String> onStyleChanged;

  const SudokuDrawerHeaderStyleSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    required this.selectedStyleName,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: sectionPadding,
          child: const Text(
            'SuDoKu Playtime',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 8),
        Padding(
          padding: sectionPadding,
          child: const Text(
            'Puzzle Style',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ...['Modern', 'Classic', 'High Contrast'].map(_buildStyleOption),
        const Divider(height: 8),
      ],
    );
  }

  Widget _buildStyleOption(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedStyleName,
      dense: true,
      visualDensity: compactDensity,
      contentPadding: sectionPadding,
      onChanged: (next) {
        if (next != null) {
          onStyleChanged(next);
        }
      },
    );
  }
}

class SudokuDrawerAudioSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final bool audioEnabled;
  final bool showBackgroundMusicControls;
  final ValueChanged<bool>? onAudioEnabledChanged;
  final bool backgroundMusicEnabled;
  final ValueChanged<bool>? onBackgroundMusicEnabledChanged;
  final double audioVolume;
  final ValueChanged<double>? onAudioVolumeChanged;

  const SudokuDrawerAudioSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    required this.audioEnabled,
    this.showBackgroundMusicControls = true,
    this.onAudioEnabledChanged,
    required this.backgroundMusicEnabled,
    this.onBackgroundMusicEnabledChanged,
    required this.audioVolume,
    this.onAudioVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).disabledColor;
    final inactiveColor = audioEnabled ? null : disabledColor;
    return Column(
      children: [
        ListTile(
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: const Text('Audio', style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(audioEnabled ? 'On' : 'Off'),
              Radio<bool?>(
                value: true,
                groupValue: audioEnabled ? true : null,
                toggleable: true,
                visualDensity: VisualDensity.compact,
                onChanged: onAudioEnabledChanged == null
                    ? null
                    : (enabled) => onAudioEnabledChanged!(enabled == true),
              ),
            ],
          ),
          onTap: onAudioEnabledChanged == null
              ? null
              : () => onAudioEnabledChanged!(!audioEnabled),
        ),
        if (showBackgroundMusicControls)
          ListTile(
            contentPadding: sectionPadding,
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            title: Text(
              'Background music',
              style: TextStyle(fontWeight: FontWeight.w600, color: inactiveColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Sounds for SuDoKu lovers',
                style: TextStyle(fontStyle: FontStyle.italic, color: inactiveColor),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  backgroundMusicEnabled ? 'On' : 'Off',
                  style: TextStyle(color: inactiveColor),
                ),
                Radio<bool?>(
                  value: true,
                  groupValue: backgroundMusicEnabled ? true : null,
                  toggleable: true,
                  visualDensity: VisualDensity.compact,
                  onChanged: (!audioEnabled || onBackgroundMusicEnabledChanged == null)
                      ? null
                      : (enabled) => onBackgroundMusicEnabledChanged!(enabled == true),
                ),
              ],
            ),
            onTap: (!audioEnabled || onBackgroundMusicEnabledChanged == null)
                ? null
                : () => onBackgroundMusicEnabledChanged!(!backgroundMusicEnabled),
          ),
        ListTile(
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: Text(
            'Volume',
            style: TextStyle(fontWeight: FontWeight.w600, color: inactiveColor),
          ),
          subtitle: SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 2.5),
            child: Slider(
              value: audioVolume.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(audioVolume * 100).round()}%',
              onChanged: (!audioEnabled || onAudioVolumeChanged == null)
                  ? null
                  : onAudioVolumeChanged,
            ),
          ),
        ),
        const Divider(height: 8),
      ],
    );
  }
}

class SudokuDrawerPremiumSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final UiState state;
  final ValueChanged<String>? onPremiumFeatureSelected;
  final VoidCallback? onUnlockPremiumSelected;
  final VoidCallback? onRestorePurchasesSelected;

  const SudokuDrawerPremiumSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    required this.state,
    this.onPremiumFeatureSelected,
    this.onUnlockPremiumSelected,
    this.onRestorePurchasesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: const ValueKey<String>('drawer-premium-status'),
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: const Text('Version'),
          trailing: Text(
            state.premiumActive ? 'Full' : 'Free',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (!state.premiumActive) ...[
          _locked(
            key: const ValueKey<String>('drawer-locked-progress-tracker'),
            title: 'Progress Tracker 🔒',
            subtitle: 'Track completed puzzles and milestones.',
            featureKey: 'progress_tracker',
          ),
          _locked(
            key: const ValueKey<String>('drawer-locked-extra-themes'),
            title: 'Extra Themes 🔒',
            subtitle: 'Unlock additional visual styles.',
            featureKey: 'extra_themes',
          ),
          _locked(
            key: const ValueKey<String>('drawer-locked-extra-sounds'),
            title: 'Sounds & Celebrations 🔒',
            subtitle: 'Unlock extra sounds and celebrations.',
            featureKey: 'extra_sounds_and_celebrations',
          ),
          ListTile(
            key: const ValueKey<String>('drawer-unlock-premium'),
            contentPadding: sectionPadding,
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Unlock Full Version'),
            onTap: onUnlockPremiumSelected,
          ),
        ],
        ListTile(
          key: const ValueKey<String>('drawer-restore-purchases'),
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          leading: const Icon(Icons.restore),
          title: const Text('Restore Purchases'),
          onTap: onRestorePurchasesSelected,
        ),
      ],
    );
  }

  Widget _locked({
    required ValueKey<String> key,
    required String title,
    required String subtitle,
    required String featureKey,
  }) {
    return ListTile(
      key: key,
      contentPadding: sectionPadding,
      minVerticalPadding: 0,
      visualDensity: compactDensity,
      dense: true,
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onPremiumFeatureSelected == null
          ? null
          : () => onPremiumFeatureSelected!(featureKey),
    );
  }
}
