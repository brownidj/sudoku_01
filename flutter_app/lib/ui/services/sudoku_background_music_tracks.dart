import 'package:flutter_app/ui/services/sudoku_background_music_tracks.g.dart';

const Map<String, String> _contentModeFolderAliases = <String, String>{
  'old_opera': 'opera',
};

String _folderForContentMode(String contentMode) {
  final normalized = contentMode.trim().toLowerCase();
  return _contentModeFolderAliases[normalized] ?? normalized;
}

List<String> backgroundTracksForContentMode(String contentMode) {
  final folder = _folderForContentMode(contentMode);
  return kBackgroundTracksByFolder[folder] ?? const <String>[];
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
