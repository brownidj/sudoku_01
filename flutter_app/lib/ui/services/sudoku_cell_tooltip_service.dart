import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';

class SudokuCellTooltipService {
  final TooltipOverlayService _tooltipOverlayService;
  final SudokuTilePreviewAudioService _tilePreviewAudioService;

  const SudokuCellTooltipService(
    this._tooltipOverlayService,
    this._tilePreviewAudioService,
  );

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
    final name = _titleCase(
      AnimalImageCache.displayNameForDigit(state.contentMode, value),
    );
    final imageAssetPath = AnimalImageCache.tileAssetPathForDigit(
      contentMode: state.contentMode,
      animalStyle: state.animalStyle,
      digit: value,
    );
    _tooltipOverlayService.show(
      context: context,
      globalPosition: globalPosition,
      text: name,
      imageAssetPath: imageAssetPath,
    );
    _tilePreviewAudioService.playForTile(
      contentMode: state.contentMode,
      digit: value,
    );
  }

  String _titleCase(String text) {
    final normalized = text.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    final words = normalized.split(RegExp(r'\s+'));
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
