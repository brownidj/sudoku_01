import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

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
          child: Text(
            UiStrings.drawerTitle(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 8),
        Padding(
          key: const ValueKey<String>('drawer-puzzle-style-section'),
          padding: sectionPadding,
          child: Text(
            UiStrings.drawerPuzzleStyleTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        RadioGroup<String>(
          groupValue: selectedStyleName,
          onChanged: (next) {
            if (next != null) {
              onStyleChanged(next);
            }
          },
          child: Column(
            children: [
              ...[
                UiStrings.styleModern(context),
                UiStrings.styleClassic(context),
                UiStrings.styleHighContrast(context),
              ].map(_buildStyleOption),
            ],
          ),
        ),
        const Divider(height: 8),
      ],
    );
  }

  Widget _buildStyleOption(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      dense: true,
      visualDensity: compactDensity,
      contentPadding: sectionPadding,
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
          key: const ValueKey<String>('drawer-audio-section'),
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: Text(
            UiStrings.drawerAudioTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                audioEnabled
                    ? UiStrings.labelOn(context)
                    : UiStrings.labelOff(context),
              ),
              Switch(
                value: audioEnabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onAudioEnabledChanged,
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
              UiStrings.drawerBackgroundMusicTitle(context),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: inactiveColor,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                UiStrings.drawerBackgroundMusicSubtitle(context),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: inactiveColor,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  backgroundMusicEnabled
                      ? UiStrings.labelOn(context)
                      : UiStrings.labelOff(context),
                  style: TextStyle(color: inactiveColor),
                ),
                Switch(
                  value: backgroundMusicEnabled,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged:
                      (!audioEnabled || onBackgroundMusicEnabledChanged == null)
                      ? null
                      : onBackgroundMusicEnabledChanged,
                ),
              ],
            ),
            onTap: (!audioEnabled || onBackgroundMusicEnabledChanged == null)
                ? null
                : () =>
                      onBackgroundMusicEnabledChanged!(!backgroundMusicEnabled),
          ),
        ListTile(
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: Text(
            UiStrings.drawerVolumeTitle(context),
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
