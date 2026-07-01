import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/ui_strings.dart';

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
          title: Text(UiStrings.drawerVersionTitle(context)),
          trailing: Text(
            state.premiumActive
                ? UiStrings.drawerVersionFull(context)
                : UiStrings.drawerVersionFree(context),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (!state.premiumActive) ...[
          _locked(
            key: const ValueKey<String>('drawer-locked-progress-tracker'),
            title: UiStrings.drawerPremiumProgressTitle(context),
            subtitle: UiStrings.drawerPremiumProgressSubtitle(context),
            featureKey: 'progress_tracker',
          ),
          _locked(
            key: const ValueKey<String>('drawer-locked-extra-themes'),
            title: UiStrings.drawerPremiumThemesTitle(context),
            subtitle: UiStrings.drawerPremiumThemesSubtitle(context),
            featureKey: 'extra_themes',
          ),
          _locked(
            key: const ValueKey<String>('drawer-locked-extra-sounds'),
            title: UiStrings.drawerPremiumSoundsTitle(context),
            subtitle: UiStrings.drawerPremiumSoundsSubtitle(context),
            featureKey: 'extra_sounds_and_celebrations',
          ),
          ListTile(
            key: const ValueKey<String>('drawer-unlock-premium'),
            contentPadding: sectionPadding,
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(UiStrings.drawerUnlockFullVersion(context)),
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
          title: Text(UiStrings.drawerRestorePurchases(context)),
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
