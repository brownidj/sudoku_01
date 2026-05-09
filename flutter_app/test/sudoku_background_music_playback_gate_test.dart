import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldAttemptBackgroundMusicPlayback', () {
    test('returns false when background music preference is off', () {
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: false,
          sessionInProgress: true,
          themeSupportsBackgroundMusic: true,
          hasSuspensions: false,
        ),
        isFalse,
      );
    });

    test('returns true only when all playback preconditions are met', () {
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          themeSupportsBackgroundMusic: true,
          hasSuspensions: false,
        ),
        isTrue,
      );
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: false,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          themeSupportsBackgroundMusic: true,
          hasSuspensions: false,
        ),
        isFalse,
      );
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: false,
          themeSupportsBackgroundMusic: true,
          hasSuspensions: false,
        ),
        isFalse,
      );
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          themeSupportsBackgroundMusic: false,
          hasSuspensions: false,
        ),
        isFalse,
      );
      expect(
        shouldAttemptBackgroundMusicPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          themeSupportsBackgroundMusic: true,
          hasSuspensions: true,
        ),
        isFalse,
      );
    });
  });
}
