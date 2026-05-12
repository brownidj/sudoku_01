import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

enum PremiumExplainerAction { dismiss, unlock }

class PremiumExplainerSheet extends StatelessWidget {
  final String? featureLabel;

  const PremiumExplainerSheet({super.key, this.featureLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featureIntro = featureLabel == null
        ? UiStrings.premiumFeatureIntroGeneric(context)
        : UiStrings.premiumFeatureIntroNamed(context, featureLabel!);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UiStrings.premiumSheetTitle(context),
                key: const ValueKey<String>('premium-sheet-title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(featureIntro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text(
                UiStrings.premiumIncludesTitle(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(UiStrings.premiumIncludesHardDifficulties(context)),
              Text(UiStrings.premiumIncludesProgress(context)),
              Text(UiStrings.premiumIncludesThemesSounds(context)),
              const SizedBox(height: 12),
              Text(
                UiStrings.premiumOneTimePurchase(context),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    key: const ValueKey<String>('premium-sheet-dismiss-button'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(PremiumExplainerAction.dismiss),
                    child: Text(UiStrings.premiumActionNotNow(context)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey<String>('premium-sheet-unlock-button'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(PremiumExplainerAction.unlock),
                    child: Text(UiStrings.premiumActionUnlock(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
