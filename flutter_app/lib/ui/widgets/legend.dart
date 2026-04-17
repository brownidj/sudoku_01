import 'package:flutter/material.dart';
import 'package:flutter_app/ui/styles.dart';

class Legend extends StatelessWidget {
  final BoardStyle style;

  const Legend({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _legendItem(style.highlightIncorrect, 'Needs Review'),
          _legendItem(style.highlightCorrect, 'Great Progress'),
          _legendItem(style.highlightGiven, 'Starter Clue'),
          _legendItem(style.highlightSolution, 'Revealed Clue'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
