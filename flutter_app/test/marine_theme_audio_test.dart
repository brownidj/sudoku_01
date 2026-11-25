import 'dart:math';

import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => MarineGameTheme.definition = null);

  test(
    'Redtail and Copperband choose only their own tunes; other fish stay silent',
    () {
      const audio = ThemeAudio(
        tilePreviewAssets: {
          1: '/audio/1_threadfin_1.mp3',
          2: '/audio/2_copperband_1.m4a',
          8: '/audio/8_redtail_1.wav',
        },
        tilePreviewVariants: {
          2: ['/audio/2_copperband_1.m4a', '/audio/2_copperband_2.m4a'],
          8: ['/audio/8_redtail_1.wav', '/audio/8_redtail_2.wav'],
        },
        backgroundMusicAssets: [
          '/audio/1_threadfin_1.mp3',
          '/audio/2_copperband_1.m4a',
          '/audio/2_copperband_2.m4a',
          '/audio/8_redtail_1.wav',
          '/audio/8_redtail_2.wav',
        ],
      );
      MarineGameTheme.definition = const ThemeDefinition(
        id: 'marine',
        displayName: 'Marine Life',
        version: 4,
        tiles: [],
        audio: audio,
        colours: ThemeColours(),
        typography: null,
      );
      final random = Random(42);
      final copperbandSelections = {
        for (var i = 0; i < 40; i++)
          audio.tilePreviewAssetForDigit(2, random: random),
      };
      expect(copperbandSelections, {
        '/audio/2_copperband_1.m4a',
        '/audio/2_copperband_2.m4a',
      });
      final selections = {
        for (var i = 0; i < 40; i++)
          audio.tilePreviewAssetForDigit(8, random: random),
      };
      expect(selections, {'/audio/8_redtail_1.wav', '/audio/8_redtail_2.wav'});
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'marine',
          digit: 8,
        ),
        isIn(selections),
      );
      expect(
        SudokuTilePreviewAudioService.audioAssetForTile(
          contentMode: 'marine',
          digit: 1,
        ),
        '/audio/1_threadfin_1.mp3',
      );
      for (final digit in [3, 4, 5, 6, 7, 9]) {
        expect(
          SudokuTilePreviewAudioService.audioAssetForTile(
            contentMode: 'marine',
            digit: digit,
          ),
          isNull,
        );
      }
      expect(
        backgroundTracksForContentMode('marine'),
        audio.backgroundMusicAssets,
      );
    },
  );

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
