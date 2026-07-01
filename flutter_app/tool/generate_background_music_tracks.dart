import 'dart:io';
import 'dart:convert';

const _inputRoot = 'assets/audio/background';
const _outputFile = 'lib/ui/services/sudoku_background_music_tracks.g.dart';

void main() {
  final root = Directory(_inputRoot);
  if (!root.existsSync()) {
    stderr.writeln('Missing directory: $_inputRoot');
    exitCode = 1;
    return;
  }

  final tracksByFolder = <String, List<String>>{};
  for (final entity in root.listSync().whereType<Directory>()) {
    final folderName = entity.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    final tracks =
        entity
            .listSync()
            .whereType<File>()
            .map((file) => file.path.replaceAll('\\', '/'))
            .where((path) => path.toLowerCase().endsWith('.mp3'))
            .map(
              (path) => path.startsWith('assets/') ? path.substring(7) : path,
            )
            .toList()
          ..sort();
    tracksByFolder[folderName] = tracks;
  }

  final folders = tracksByFolder.keys.toList()..sort();
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Run: dart run tool/generate_background_music_tracks.dart')
    ..writeln()
    ..writeln('const Map<String, List<String>> kBackgroundTracksByFolder = {');

  for (final folder in folders) {
    buffer.writeln('  ${jsonEncode(folder)}: <String>[');
    for (final track in tracksByFolder[folder]!) {
      buffer.writeln('    ${jsonEncode(track)},');
    }
    buffer.writeln('  ],');
  }

  buffer
    ..writeln('};')
    ..writeln();

  File(_outputFile).writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote $_outputFile (${folders.length} folders).');
}
