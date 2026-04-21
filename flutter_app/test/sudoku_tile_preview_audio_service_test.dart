import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SudokuTilePreviewAudioService.audioAssetForTile', () {
    test('maps animals digits to corresponding assets', () {
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'animals',
          digit: 3,
        ),
        'audio/animals/cheetah.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'animals',
          digit: 8,
        ),
        'audio/animals/hippos.mp3',
      );
    });

    test('maps instruments digits to corresponding assets', () {
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'instruments',
          digit: 6,
        ),
        'audio/music/drum.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'instruments',
          digit: 9,
        ),
        'audio/music/ukulele.mp3',
      );
    });

    test('returns null for unsupported mode and invalid digits', () {
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'numbers',
          digit: 1,
        ),
        isNull,
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'animals',
          digit: 0,
        ),
        isNull,
      );
    });
  });
}
