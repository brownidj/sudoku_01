import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/services/app_version_service.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';

class SudokuDrawerAboutSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final AppVersionService appVersionService;

  const SudokuDrawerAboutSection({
    super.key,
    required this.sectionPadding,
    required this.appVersionService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        const Divider(height: 8),
        Padding(
          padding: sectionPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              key: const ValueKey<String>('drawer-about-chip'),
              avatar: const Icon(Icons.info_outline, size: 18),
              label: Text(UiStrings.drawerAboutChip(context)),
              onPressed: () async {
                final versionLabel = await appVersionService.loadDisplayVersion();
                if (!context.mounted) {
                  return;
                }
                await showInfoSheet(
                  context: context,
                  title: UiStrings.drawerAboutTitle(context),
                  message: UiStrings.drawerAboutMessage(context, versionLabel),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SudokuDrawerDebugSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final VoidCallback? onLoadCorrectionScenario;
  final VoidCallback? onLoadExhaustedCorrectionScenario;
  final VoidCallback? onResetEntitlementToFreeSelected;

  const SudokuDrawerDebugSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    this.onLoadCorrectionScenario,
    this.onLoadExhaustedCorrectionScenario,
    this.onResetEntitlementToFreeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visible = onLoadCorrectionScenario != null ||
        onLoadExhaustedCorrectionScenario != null ||
        onResetEntitlementToFreeSelected != null;
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const Divider(height: 8),
        Padding(
          padding: sectionPadding,
          child: Text(
            UiStrings.drawerDebugTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          leading: const Icon(Icons.science_outlined),
          title: Text(UiStrings.drawerDebugLoadCorrectionTitle(context)),
          subtitle: Text(UiStrings.drawerDebugLoadCorrectionSubtitle(context)),
          onTap: onLoadCorrectionScenario,
        ),
        if (onLoadExhaustedCorrectionScenario != null)
          ListTile(
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.warning_amber_outlined),
            title: Text(UiStrings.drawerDebugLoadExhaustedTitle(context)),
            subtitle: Text(UiStrings.drawerDebugLoadExhaustedSubtitle(context)),
            onTap: onLoadExhaustedCorrectionScenario,
          ),
        if (onResetEntitlementToFreeSelected != null)
          ListTile(
            key: const ValueKey<String>('drawer-reset-entitlement-free'),
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.restart_alt),
            title: Text(UiStrings.drawerDebugResetEntitlementTitle(context)),
            subtitle: Text(UiStrings.drawerDebugResetEntitlementSubtitle(context)),
            onTap: onResetEntitlementToFreeSelected,
          ),
      ],
    );
  }
}
