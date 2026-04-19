import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_note_painter.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardPainter extends CustomPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  SudokuBoardPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final layout = layoutForSize(size);
    final boardRect = Rect.fromLTWH(
      layout.originX,
      layout.originY,
      layout.boardSize,
      layout.boardSize,
    );

    final boardPaint = Paint()..color = style.boardBg;
    canvas.drawRect(boardRect, boardPaint);

    _drawCells(canvas, layout, BoardTheme(style));
    _drawGrid(canvas, layout);
    // Notes badge removed; notes mode is indicated via the UI toggle.
  }

  void _drawCells(Canvas canvas, BoardLayout layout, BoardTheme theme) {
    final selected = state.selected;
    final selRow = selected?.row;
    final selCol = selected?.col;
    final selBoxRow = selRow == null ? null : selRow ~/ 3;
    final selBoxCol = selCol == null ? null : selCol ~/ 3;

    final cellSize = layout.cellSize;
    final notePainter = BoardNotePainter(
      style: style,
      contentMode: state.contentMode,
      noteImagesBySize: noteImagesBySize,
      devicePixelRatio: devicePixelRatio,
      animalColorFilterResolver: _animalColorFilter,
    );
    for (var r = 0; r < 9; r += 1) {
      final row = state.board.cells[r];
      for (var c = 0; c < 9; c += 1) {
        final cell = row[c];
        final x0 = layout.originX + c * cellSize;
        final y0 = layout.originY + r * cellSize;
        final rect = Rect.fromLTWH(x0, y0, cellSize, cellSize);

        final peerRowCol =
            selRow != null && selCol != null && (r == selRow || c == selCol);
        final peerBox =
            selBoxRow != null &&
            selBoxCol != null &&
            (r ~/ 3 == selBoxRow) &&
            (c ~/ 3 == selBoxCol);

        final model = theme.cellModel(
          cell: cell,
          gameOver: state.gameOver,
          peerRowCol: peerRowCol,
          peerBox: peerBox,
        );

        canvas.drawRect(rect, Paint()..color = model.background);
        if (model.showReverted) {
          canvas.drawRect(rect, Paint()..color = style.highlightReverted);
          _drawOutline(canvas, rect, style.outlineReverted, 2);
        }

        if (state.gameOver) {
          Color? highlight;
          if (model.showIncorrect) {
            highlight = style.highlightIncorrect;
          } else if (model.showSolution) {
            highlight = style.highlightSolution;
          } else if (model.showGiven) {
            highlight = style.highlightGiven;
          } else if (model.showCorrect) {
            highlight = style.highlightCorrect;
          }
          if (highlight != null) {
            canvas.drawRect(rect, Paint()..color = highlight);
          }
        } else {
          if (model.showSelection) {
            _drawOutline(canvas, rect, style.outlineSelected, 3);
          } else if (model.showConflict) {
            _drawOutline(canvas, rect, style.outlineConflict, 3);
          }
        }

        if (cell.value != null) {
          if (state.contentMode != 'numbers' &&
              animalImages.containsKey(cell.value)) {
            _drawAnimal(canvas, rect, animalImages[cell.value]!, cell.value!);
          } else {
            _drawValue(
              canvas,
              rect,
              AnimalImageCache.tileLabelForDigit(
                state.contentMode,
                cell.value!,
              ),
              cell.given,
              cellSize,
            );
          }
        } else if (cell.notes.isNotEmpty) {
          notePainter.drawNotes(canvas, rect, cell.notes);
        }

        // Solution/correct/given outlines handled above.
      }
    }
  }

  void _drawOutline(Canvas canvas, Rect rect, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawRect(rect, paint);
  }

  void _drawValue(
    Canvas canvas,
    Rect rect,
    String valueLabel,
    bool given,
    double cellSize,
  ) {
    final fontSize = cellSize * 0.6;
    final textPainter = TextPainter(
      text: TextSpan(
        text: valueLabel,
        style: TextStyle(
          color: given ? style.givenColor : style.valueColor,
          fontWeight: given ? FontWeight.bold : FontWeight.normal,
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

  void _drawAnimal(Canvas canvas, Rect rect, ui.Image image, int digit) {
    final targetSize = _animalTargetSize(rect.width, digit);
    final left = rect.left + (rect.width - targetSize) / 2;
    final top = rect.top + (rect.height - targetSize) / 2;
    final target = Rect.fromLTWH(left, top, targetSize, targetSize);
    paintImage(
      canvas: canvas,
      rect: target,
      image: image,
      fit: BoxFit.contain,
      colorFilter: _animalColorFilter(digit),
    );
  }

  ColorFilter? _animalColorFilter(int digit) {
    if (digit == 3) {
      return const ColorFilter.mode(Color(0xFFF8F0E2), BlendMode.modulate);
    }
    return null;
  }

  double _animalTargetSize(double cellSize, int digit) {
    return cellSize * 0.7;
  }

  void _drawGrid(Canvas canvas, BoardLayout layout) {
    final thinPaint = Paint()
      ..color = style.gridThin
      ..strokeWidth = 1.0;
    final thickPaint = Paint()
      ..color = style.gridThick
      ..strokeWidth = 3.0;

    for (var i = 1; i < 9; i += 1) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thinPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thinPaint,
      );
    }

    for (var i = 0; i <= 9; i += 3) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thickPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thickPaint,
      );
    }
  }

  // Notes badge removed.

  @override
  bool shouldRepaint(covariant SudokuBoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.style != style ||
        oldDelegate.animalImages != animalImages ||
        oldDelegate.noteImagesBySize != noteImagesBySize;
  }
}
