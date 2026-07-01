import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _translatableKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('all app_en.arb keys exist in every non-English ARB', () {
    final l10nDir = Directory('lib/l10n');
    final enFile = File('${l10nDir.path}/app_en.arb');
    expect(enFile.existsSync(), isTrue, reason: 'Missing app_en.arb');

    final enArb = _readArb(enFile);
    final enKeys = _translatableKeys(enArb);

    final localeFiles =
        l10nDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.arb'))
            .where((f) => !f.path.endsWith('app_en.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(localeFiles, isNotEmpty, reason: 'No non-English ARB files found');

    for (final file in localeFiles) {
      final arb = _readArb(file);
      final keys = _translatableKeys(arb);
      final missing = enKeys.difference(keys).toList()..sort();

      expect(
        missing,
        isEmpty,
        reason:
            '${file.path} is missing ${missing.length} keys from app_en.arb: $missing',
      );
    }
  });
}
