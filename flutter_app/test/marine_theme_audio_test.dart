import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => MarineGameTheme.definition = null);

  test('Marine Life resolves installed creature audio and music paths', () {
    MarineGameTheme.definition = ThemeDefinition(
      id: 'marine',
      displayName: 'Marine Life',
      version: 2,
      tiles: const [],
      audio: ThemeAudio(
        tilePreviewAssets: {
          for (var digit = 1; digit <= 9; digit++)
            digit: '/installed/marine/audio/tiles/$digit.mp3',
        },
        backgroundMusicAssets: const ['/installed/marine/audio/music/song.mp3'],
      ),
      colours: const ThemeColours(),
      typography: null,
    );
    for (var digit = 1; digit <= 9; digit++) {
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'marine',
          digit: digit,
        ),
        '/installed/marine/audio/tiles/$digit.mp3',
      );
    }
    expect(backgroundTracksForContentMode('marine'), [
      '/installed/marine/audio/music/song.mp3',
    ]);
    expect(
      SudokuTilePreviewAudioService.audioAssetForTile(
        contentMode: 'marine',
        digit: 0,
      ),
      isNull,
    );
  });

  test('missing installation provides no Marine Life audio', () {
    MarineGameTheme.definition = null;
    expect(backgroundTracksForContentMode('marine'), isEmpty);
    expect(
      SudokuTilePreviewAudioService.audioAssetForTile(
        contentMode: 'marine',
        digit: 1,
      ),
      isNull,
    );
  });
}
