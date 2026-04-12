import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';

class SudokuCellTooltipService {
  final TooltipOverlayService _tooltipOverlayService;

  const SudokuCellTooltipService(this._tooltipOverlayService);

  void showForCell({
    required BuildContext context,
    required UiState state,
    required Coord coord,
    required Offset globalPosition,
  }) {
    if (state.contentMode == 'numbers') {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    final value = cell.value;
    if (value == null) {
      return;
    }
    final name = AnimalImageCache.displayNameForDigit(state.contentMode, value);
    _tooltipOverlayService.show(
      context: context,
      globalPosition: globalPosition,
      text: name,
    );
  }
}
