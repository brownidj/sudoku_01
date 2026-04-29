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

    test('maps old opera digits with available audio assets only', () {
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 1,
        ),
        'audio/opera/bass.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 2,
        ),
        'audio/opera/baritone.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 3,
        ),
        'audio/opera/tenor.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 5,
        ),
        'audio/opera/soprano.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 6,
        ),
        'audio/opera/royal_court_singer.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 7,
        ),
        'audio/opera/modern_opera.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 4,
        ),
        'audio/opera/mezzo_soprano.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 8,
        ),
        'audio/opera/masked_phantom_style.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 9,
        ),
        'audio/opera/opera_diva_comic.mp3',
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'old_opera',
          digit: 10,
        ),
        isNull,
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
