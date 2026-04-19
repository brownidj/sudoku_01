import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/note_layout.dart';
import 'package:flutter_app/ui/styles.dart';

typedef AnimalColorFilterResolver = ColorFilter? Function(int digit);

class BoardNotePainter {
  final BoardStyle style;
  final String contentMode;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;
  final AnimalColorFilterResolver animalColorFilterResolver;

  const BoardNotePainter({
    required this.style,
    required this.contentMode,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
    required this.animalColorFilterResolver,
  });

  void drawNotes(Canvas canvas, Rect rect, List<int> notes) {
    final notesSorted = List<int>.from(notes)..sort();
    if (notesSorted.isEmpty) {
      return;
    }
    final gridSize = noteGridSize(notesSorted.length);
    final subCellSize = rect.width / gridSize;
    if (contentMode == 'numbers') {
      _drawNumberNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }

    final logicalSize = subCellSize * 0.95;
    final targetPx = logicalSize * devicePixelRatio;
    final sizePx = bestNoteSize(targetPx, noteImagesBySize.keys);
    if (sizePx == 0 || !noteImagesBySize.containsKey(sizePx)) {
      _drawNumberNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }

    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final cellLeft = rect.left + col * subCellSize;
      final cellTop = rect.top + row * subCellSize;
      final cellRect = Rect.fromLTWH(
        cellLeft,
        cellTop,
        subCellSize,
        subCellSize,
      );
      final image = noteImagesBySize[sizePx]?[digit];
      if (image == null) {
        _drawNoteDigit(canvas, cellRect, digit, contentMode: 'numbers');
        continue;
      }
      final left = cellLeft + (subCellSize - logicalSize) / 2;
      final top = cellTop + (subCellSize - logicalSize) / 2;
      final target = Rect.fromLTWH(left, top, logicalSize, logicalSize);
      paintImage(
        canvas: canvas,
        rect: target,
        image: image,
        fit: BoxFit.contain,
        colorFilter: animalColorFilterResolver(digit),
      );
    }
  }

  void _drawNumberNotes(
    Canvas canvas,
    Rect rect,
    List<int> notesSorted,
    int gridSize,
    double subCellSize,
  ) {
    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final cellLeft = rect.left + col * subCellSize;
      final cellTop = rect.top + row * subCellSize;
      final cellRect = Rect.fromLTWH(
        cellLeft,
        cellTop,
        subCellSize,
        subCellSize,
      );
      _drawNoteDigit(canvas, cellRect, digit, contentMode: contentMode);
    }
  }

  void _drawNoteDigit(
    Canvas canvas,
    Rect rect,
    int digit, {
    required String contentMode,
  }) {
    final fontSize = rect.width * 0.6;
    final label = AnimalImageCache.tileLabelForDigit(contentMode, digit);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: style.valueColor.withOpacity(0.7),
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }
}
