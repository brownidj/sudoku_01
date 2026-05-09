import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/app_version_service.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer_sections.dart';

class SudokuDrawer extends StatelessWidget {
  static const _sectionPadding = EdgeInsets.symmetric(horizontal: 16);
  static const _compactDensity = VisualDensity(horizontal: 0, vertical: -4);
  final UiState state;
  final ValueChanged<String> onAnimalStyleChanged;
  final ValueChanged<String> onStyleChanged;
  final bool audioEnabled;
  final ValueChanged<bool>? onAudioEnabledChanged;
  final double audioVolume;
  final ValueChanged<double>? onAudioVolumeChanged;
  final bool backgroundMusicEnabled;
  final ValueChanged<bool>? onBackgroundMusicEnabledChanged;
  final ValueChanged<String>? onPremiumFeatureSelected;
  final VoidCallback? onUnlockPremiumSelected;
  final VoidCallback? onRestorePurchasesSelected;
  final VoidCallback? onLoadCorrectionScenario;
  final VoidCallback? onLoadExhaustedCorrectionScenario;
  final VoidCallback? onResetEntitlementToFreeSelected;
  final bool showDebugTools;
  final AppVersionService appVersionService;

  const SudokuDrawer({
    super.key,
    required this.state,
    required this.onAnimalStyleChanged,
    required this.onStyleChanged,
    this.audioEnabled = true,
    this.onAudioEnabledChanged,
    this.audioVolume = 0.5,
    this.onAudioVolumeChanged,
    this.backgroundMusicEnabled = true,
    this.onBackgroundMusicEnabledChanged,
    this.onPremiumFeatureSelected,
    this.onUnlockPremiumSelected,
    this.onRestorePurchasesSelected,
    this.onLoadCorrectionScenario,
    this.onLoadExhaustedCorrectionScenario,
    this.onResetEntitlementToFreeSelected,
    this.showDebugTools = AppDebug.enabled,
    this.appVersionService = const AppVersionService(),
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SudokuDrawerHeaderStyleSection(
              sectionPadding: _sectionPadding,
              compactDensity: _compactDensity,
              selectedStyleName: state.styleName,
              onStyleChanged: onStyleChanged,
            ),
            SudokuDrawerAudioSection(
              sectionPadding: _sectionPadding,
              compactDensity: _compactDensity,
              audioEnabled: audioEnabled,
              onAudioEnabledChanged: onAudioEnabledChanged,
              showBackgroundMusicControls:
                  state.contentMode == 'butterflies' ||
                  state.contentMode == 'old_opera',
              backgroundMusicEnabled: backgroundMusicEnabled,
              onBackgroundMusicEnabledChanged: onBackgroundMusicEnabledChanged,
              audioVolume: audioVolume,
              onAudioVolumeChanged: onAudioVolumeChanged,
            ),
            SudokuDrawerPremiumSection(
              sectionPadding: _sectionPadding,
              compactDensity: _compactDensity,
              state: state,
              onPremiumFeatureSelected: onPremiumFeatureSelected,
              onUnlockPremiumSelected: onUnlockPremiumSelected,
              onRestorePurchasesSelected: onRestorePurchasesSelected,
            ),
            SudokuDrawerAboutSection(
              sectionPadding: _sectionPadding,
              appVersionService: appVersionService,
            ),
            if (showDebugTools)
              SudokuDrawerDebugSection(
                sectionPadding: _sectionPadding,
                compactDensity: _compactDensity,
                onLoadCorrectionScenario: onLoadCorrectionScenario,
                onLoadExhaustedCorrectionScenario:
                    onLoadExhaustedCorrectionScenario,
                onResetEntitlementToFreeSelected:
                    onResetEntitlementToFreeSelected,
              ),
          ],
        ),
      ),
    );
  }
}
