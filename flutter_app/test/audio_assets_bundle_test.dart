import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _expectBundledMp3sUnder(String relativeDir) async {
  final dir = Directory(relativeDir);
  expect(dir.existsSync(), isTrue, reason: 'Missing directory: $relativeDir');

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.mp3'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  expect(files, isNotEmpty, reason: 'No mp3 files found in $relativeDir');

  for (final file in files) {
    final fileName = file.uri.pathSegments.last;
    final assetKey = '$relativeDir/$fileName';
    final data = await rootBundle.load(assetKey);
    expect(
      data.lengthInBytes,
      greaterThan(0),
      reason: 'Bundled asset is empty: $assetKey',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bundles all animal celebration audio files', (tester) async {
    await _expectBundledMp3sUnder('assets/audio/animals');
  });

  testWidgets('bundles all instrument celebration audio files', (tester) async {
    await _expectBundledMp3sUnder('assets/audio/music');
  });
}
