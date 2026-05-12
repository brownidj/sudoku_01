import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_service.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_app/ui/ui_strings.dart';

abstract class CellTooltipOverlay {
  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
    String? imageAssetPath,
  });
}

class TooltipOverlayAdapter implements CellTooltipOverlay {
  final TooltipOverlayService _service;

  const TooltipOverlayAdapter(this._service);

  @override
  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
    String? imageAssetPath,
  }) {
    _service.show(
      context: context,
      globalPosition: globalPosition,
      text: text,
      imageAssetPath: imageAssetPath,
    );
  }
}

abstract class TilePreviewAudioController {
  bool playForTile({required String contentMode, required int digit});

  Duration get maxClipDuration;

  String? audioAssetForTile({required String contentMode, required int digit});
}

class TilePreviewAudioControllerAdapter implements TilePreviewAudioController {
  final SudokuTilePreviewAudioService _service;

  const TilePreviewAudioControllerAdapter(this._service);

  @override
  bool playForTile({required String contentMode, required int digit}) {
    return _service.playForTile(contentMode: contentMode, digit: digit);
  }

  @override
  Duration get maxClipDuration => _service.maxClipDuration;

  @override
  String? audioAssetForTile({required String contentMode, required int digit}) {
    return SudokuTilePreviewAudioService.audioAssetForTile(
      contentMode: contentMode,
      digit: digit,
    );
  }
}

abstract class BackgroundMusicController {
  void suspend(String reason);

  void resume(String reason);
}

class BackgroundMusicControllerAdapter implements BackgroundMusicController {
  final SudokuBackgroundMusicService _service;

  const BackgroundMusicControllerAdapter(this._service);

  @override
  void suspend(String reason) => _service.suspend(reason);

  @override
  void resume(String reason) => _service.resume(reason);
}

class SudokuCellTooltipService {
  final CellTooltipOverlay _tooltipOverlayService;
  final TilePreviewAudioController _tilePreviewAudioService;
  final BackgroundMusicController _backgroundMusicService;

  const SudokuCellTooltipService(
    this._tooltipOverlayService,
    this._tilePreviewAudioService,
    this._backgroundMusicService,
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
    final audioAsset = _tilePreviewAudioService.audioAssetForTile(
      contentMode: state.contentMode,
      digit: value,
    );
    if (audioAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UiStrings.audioUnavailableTile(context)),
        ),
      );
      return;
    }
    final started = _tilePreviewAudioService.playForTile(
      contentMode: state.contentMode,
      digit: value,
    );
    if (!started) {
      return;
    }
    _backgroundMusicService.suspend('tile-preview');
    Future<void>.delayed(_tilePreviewAudioService.maxClipDuration, () {
      _backgroundMusicService.resume('tile-preview');
    });
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
