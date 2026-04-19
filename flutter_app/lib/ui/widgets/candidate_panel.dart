import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';

class CandidatePanel extends StatelessWidget {
  final bool visible;
  final List<int> candidateDigits;
  final bool showImages;
  final String contentMode;
  final bool notesMode;
  final Set<int> selectedNotes;
  final Map<int, ui.Image> animalImages;
  final ValueChanged<int> onDigitSelected;
  final ValueChanged<int>? onDigitLongPressed;

  const CandidatePanel({
    super.key,
    required this.visible,
    required this.candidateDigits,
    required this.showImages,
    required this.contentMode,
    required this.notesMode,
    required this.selectedNotes,
    required this.animalImages,
    required this.onDigitSelected,
    this.onDigitLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final digit in candidateDigits)
            Builder(
              builder: (context) {
                return SizedBox(
                  width: 52,
                  height: 52,
                  child: GestureDetector(
                    onLongPressStart: contentMode != 'numbers'
                        ? (_) {
                            final name = AnimalImageCache.displayNameForDigit(
                              contentMode,
                              digit,
                            );
                            showInfoSheet(context: context, message: name);
                          }
                        : null,
                    onLongPress: onDigitLongPressed == null
                        ? null
                        : () => onDigitLongPressed!(digit),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            notesMode && selectedNotes.contains(digit)
                            ? const Color(0xFFCFEFCD)
                            : (showImages ? Colors.white : null),
                      ),
                      onPressed: () => onDigitSelected(digit),
                      child: _candidateOption(digit),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _candidateOption(int digit) {
    if (showImages) {
      return _animalOption(digit);
    }
    final label = AnimalImageCache.tileLabelForDigit(contentMode, digit);
    return Text(label);
  }

  Widget _animalOption(int digit) {
    final image = animalImages[digit];
    if (image == null) {
      return Text(AnimalImageCache.tileLabelForDigit(contentMode, digit));
    }
    return SizedBox(
      width: 38,
      height: 38,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Transform.scale(
          scaleY: contentMode == 'animals' && digit == 5 ? 1.15 : 1.0,
          child: RawImage(
            image: image,
            color: _animalTintColor(digit),
            colorBlendMode: _animalTintColor(digit) != null
                ? BlendMode.modulate
                : null,
          ),
        ),
      ),
    );
  }

  Color? _animalTintColor(int digit) {
    if (contentMode == 'animals' && digit == 3) {
      return const Color(0xFFF8F0E2);
    }
    return null;
  }
}
