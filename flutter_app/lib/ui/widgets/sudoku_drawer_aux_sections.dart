import 'package:flutter/material.dart';
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
              label: const Text('About'),
              onPressed: () async {
                final versionLabel = await appVersionService.loadDisplayVersion();
                if (!context.mounted) {
                  return;
                }
                await showInfoSheet(
                  context: context,
                  title: 'About',
                  message:
                      'Version: $versionLabel\n\n'
                      'The Angry Grannies Dev Team\n'
                      'dev - DayDay\n'
                      'dev - SudokuQueen\n'
                      'tech advisor - Icy',
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
          child: const Text('Debug', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        ListTile(
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          leading: const Icon(Icons.science_outlined),
          title: const Text('Load Correction Scenario'),
          subtitle: const Text('Temporary control for assisted-recovery testing.'),
          onTap: onLoadCorrectionScenario,
        ),
        if (onLoadExhaustedCorrectionScenario != null)
          ListTile(
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Load Exhausted Correction Scenario'),
            subtitle: const Text('Temporary control for undo-only recovery testing.'),
            onTap: onLoadExhaustedCorrectionScenario,
          ),
        if (onResetEntitlementToFreeSelected != null)
          ListTile(
            key: const ValueKey<String>('drawer-reset-entitlement-free'),
            minVerticalPadding: 0,
            visualDensity: compactDensity,
            dense: true,
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset Full Version (Debug)'),
            subtitle: const Text('Sets local entitlement to Free for purchase retesting.'),
            onTap: onResetEntitlementToFreeSelected,
          ),
      ],
    );
  }
}
