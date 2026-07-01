import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class LaunchScreenHintCarousel extends StatelessWidget {
  final List<String> hints;
  final int hintIndex;
  final ValueChanged<int> onHintIndexChanged;

  const LaunchScreenHintCarousel({
    super.key,
    required this.hints,
    required this.hintIndex,
    required this.onHintIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: UiStrings.tooltipPrevHint(context),
                onPressed: () => onHintIndexChanged(
                  (hintIndex - 1 + hints.length) % hints.length,
                ),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  UiStrings.launchHintsTitle(context),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14) + 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: UiStrings.tooltipNextHint(context),
                onPressed: () =>
                    onHintIndexChanged((hintIndex + 1) % hints.length),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                hints[hintIndex],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
