import 'package:flutter_app/ui/services/sudoku_background_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SudokuBackgroundMusicService.shouldAttemptPlayback', () {
    test('returns false when background music preference is off', () {
      expect(
        SudokuBackgroundMusicService.shouldAttemptPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: false,
          sessionInProgress: true,
          hasSuspensions: false,
        ),
        isFalse,
      );
    });

    test('returns true only when all playback preconditions are met', () {
      expect(
        SudokuBackgroundMusicService.shouldAttemptPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          hasSuspensions: false,
        ),
        isTrue,
      );
      expect(
        SudokuBackgroundMusicService.shouldAttemptPlayback(
          audioEnabled: false,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          hasSuspensions: false,
        ),
        isFalse,
      );
      expect(
        SudokuBackgroundMusicService.shouldAttemptPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: false,
          hasSuspensions: false,
        ),
        isFalse,
      );
      expect(
        SudokuBackgroundMusicService.shouldAttemptPlayback(
          audioEnabled: true,
          backgroundMusicEnabled: true,
          sessionInProgress: true,
          hasSuspensions: true,
        ),
        isFalse,
      );
    });
  });
}
