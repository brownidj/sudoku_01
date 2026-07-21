import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
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
  final VoidCallback? onRedeemCodeSelected;
  final VoidCallback? onLoadCorrectionScenario;
  final VoidCallback? onLoadExhaustedCorrectionScenario;
  final VoidCallback? onResetEntitlementToFreeSelected;
  final String? selectedLanguageCode;
  final ValueChanged<String>? onLanguageChanged;
  final bool showDebugTools;
  final bool showResetEntitlementToFree;
  final AppVersionService appVersionService;
  final PremiumPolicyService premiumPolicyService;

  const SudokuDrawer({
    super.key,
    required this.state,
    required this.onAnimalStyleChanged,
    required this.onStyleChanged,
    this.audioEnabled = true,
    this.onAudioEnabledChanged,
    this.audioVolume = 0.4,
    this.onAudioVolumeChanged,
    this.backgroundMusicEnabled = true,
    this.onBackgroundMusicEnabledChanged,
    this.onPremiumFeatureSelected,
    this.onUnlockPremiumSelected,
    this.onRestorePurchasesSelected,
    this.onRedeemCodeSelected,
    this.onLoadCorrectionScenario,
    this.onLoadExhaustedCorrectionScenario,
    this.onResetEntitlementToFreeSelected,
    this.selectedLanguageCode,
    this.onLanguageChanged,
    this.showDebugTools = AppDebug.enabled,
    this.showResetEntitlementToFree = AppDebug.enabled,
    this.appVersionService = const AppVersionService(),
    this.premiumPolicyService = const PremiumPolicyService(),
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
              showBackgroundMusicControls: premiumPolicyService
                  .isBackgroundMusicThemeMode(state.contentMode),
              backgroundMusicEnabled: backgroundMusicEnabled,
              onBackgroundMusicEnabledChanged: onBackgroundMusicEnabledChanged,
              audioVolume: audioVolume,
              onAudioVolumeChanged: onAudioVolumeChanged,
            ),
            SudokuDrawerLanguageSection(
              sectionPadding: _sectionPadding,
              compactDensity: _compactDensity,
              selectedLanguageCode: selectedLanguageCode,
              onLanguageChanged: onLanguageChanged,
              showExpandedMenuForScreenshot:
                  ScreenshotMode.enabled && ScreenshotMode.isDrawerOpen,
            ),
            SudokuDrawerPremiumSection(
              sectionPadding: _sectionPadding,
              compactDensity: _compactDensity,
              state: state,
              onPremiumFeatureSelected: onPremiumFeatureSelected,
              onUnlockPremiumSelected: onUnlockPremiumSelected,
              onRestorePurchasesSelected: onRestorePurchasesSelected,
              onRedeemCodeSelected: onRedeemCodeSelected,
              showRedeemCode: defaultTargetPlatform == TargetPlatform.iOS,
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
                onResetEntitlementToFreeSelected: showResetEntitlementToFree
                    ? onResetEntitlementToFreeSelected
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
