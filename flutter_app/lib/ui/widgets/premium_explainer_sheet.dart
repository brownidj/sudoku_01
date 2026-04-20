import 'package:flutter/material.dart';

enum PremiumExplainerAction { dismiss, unlock }

class PremiumExplainerSheet extends StatelessWidget {
  final String? featureLabel;

  const PremiumExplainerSheet({super.key, this.featureLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featureIntro = featureLabel == null
        ? 'Premium gives you the full Sudoku experience in one purchase.'
        : '$featureLabel is available in Premium.';
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock Premium',
                key: const ValueKey<String>('premium-sheet-title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(featureIntro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text(
                'Premium includes:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text('• Hard and Nigh Impossible difficulties'),
              const Text('• Progress tracking and personal bests'),
              const Text('• Extra themes, sounds, and celebrations'),
              const SizedBox(height: 12),
              Text(
                'One-time purchase. No subscription.',
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
                    child: const Text('Not now'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey<String>('premium-sheet-unlock-button'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(PremiumExplainerAction.unlock),
                    child: const Text('Unlock Premium'),
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
