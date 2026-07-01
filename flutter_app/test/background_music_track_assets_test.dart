import 'dart:io';

import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_tracks.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all configured background music tracks exist under assets/', () {
    for (final track in allConfiguredBackgroundTracks()) {
      final file = File('assets/$track');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Missing background track asset: ${file.path}',
      );
    }
  });

  test('generated background track map matches asset directories', () {
    final generated = kBackgroundTracksByFolder.map(
      (key, value) => MapEntry(key, List<String>.from(value)..sort()),
    );
    final fromDisk = <String, List<String>>{};
    final root = Directory('assets/audio/background');

    for (final folder in root.listSync().whereType<Directory>()) {
      final folderName = folder.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      final tracks =
          folder
              .listSync()
              .whereType<File>()
              .map((file) => file.path.replaceAll('\\', '/'))
              .where((path) => path.toLowerCase().endsWith('.mp3'))
              .map(
                (path) => path.startsWith('assets/') ? path.substring(7) : path,
              )
              .toList()
            ..sort();
      fromDisk[folderName] = tracks;
    }

    expect(
      generated,
      equals(fromDisk),
      reason:
          'Background track map is stale. Run: dart run tool/generate_background_music_tracks.dart',
    );
  });
}
