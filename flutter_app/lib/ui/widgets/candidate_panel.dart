import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/animal_cache.dart';

class CandidatePanel extends StatelessWidget {
  final bool visible;
  final List<int> candidateDigits;
  final bool showAnimals;
  final bool notesMode;
  final Set<int> selectedNotes;
  final Map<int, ui.Image> animalImages;
  final ValueChanged<int> onDigitSelected;

  const CandidatePanel({
    super.key,
    required this.visible,
    required this.candidateDigits,
    required this.showAnimals,
    required this.notesMode,
    required this.selectedNotes,
    required this.animalImages,
    required this.onDigitSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final digit in candidateDigits)
              Builder(
                builder: (context) {
                  final tooltipKey = GlobalKey<TooltipState>();
                  return SizedBox(
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onLongPress: showAnimals
                          ? () => tooltipKey.currentState?.ensureTooltipVisible()
                          : null,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: notesMode && selectedNotes.contains(digit)
                              ? const Color(0xFFF6BABA)
                              : (showAnimals ? Colors.white : null),
                        ),
                        onPressed: () => onDigitSelected(digit),
                        child: showAnimals
                            ? _animalOption(digit, tooltipKey)
                            : (digit == 0 ? const Icon(Icons.clear) : Text('$digit')),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _animalOption(int digit, GlobalKey<TooltipState> tooltipKey) {
    if (digit == 0) {
      return const Icon(Icons.clear);
    }
    final image = animalImages[digit];
    if (image == null) {
      return Text('$digit');
    }
    final name = AnimalImageCache.nameForDigit(digit);
    return Tooltip(
      key: tooltipKey,
      message: name,
      triggerMode: TooltipTriggerMode.manual,
      child: SizedBox(
        width: 32,
        height: 32,
        child: FittedBox(
          fit: BoxFit.contain,
          child: RawImage(image: image),
        ),
      ),
    );
  }
}
