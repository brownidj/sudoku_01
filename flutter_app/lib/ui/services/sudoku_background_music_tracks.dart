import 'package:flutter_app/ui/services/sudoku_background_music_tracks.g.dart';
import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';

List<String> backgroundTracksForContentMode(String contentMode) {
  if (MarineGameTheme.isDownloaded(contentMode)) {
    return MarineGameTheme
            .definitions[contentMode]
            ?.audio
            ?.backgroundMusicAssets ??
        const [];
  }
  if (!BundledThemeRepository.hasTheme(contentMode)) {
    return const <String>[];
  }
  return BundledThemeRepository.themeDefinitionFor(
        contentMode,
      ).audio?.backgroundMusicAssets ??
      const <String>[];
}

Iterable<String> allConfiguredBackgroundTracks() sync* {
  for (final tracks in kBackgroundTracksByFolder.values) {
    yield* tracks;
  }
}

bool shouldAttemptBackgroundMusicPlayback({
  required bool audioEnabled,
  required bool backgroundMusicEnabled,
  required bool sessionInProgress,
  required bool themeSupportsBackgroundMusic,
  required bool hasSuspensions,
}) {
  return audioEnabled &&
      backgroundMusicEnabled &&
      sessionInProgress &&
      themeSupportsBackgroundMusic &&
      !hasSuspensions;
}
