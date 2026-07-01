import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UiStrings does not bypass ARB localization for shell/menu labels', () {
    final uiStrings = File('lib/ui/ui_strings.dart').readAsStringSync();

    expect(
      uiStrings.contains('Localizations.localeOf(context).languageCode'),
      isFalse,
      reason:
          'UiStrings should not branch on locale manually; use AppLocalizations keys.',
    );
    expect(
      uiStrings.contains("Shells (new!)"),
      isFalse,
      reason:
          'Shells label must come from ARB, not hardcoded fallback text in UiStrings.',
    );
  });

  test('SudokuVersionAppBar does not hardcode long UI tooltip strings', () {
    final appBar = File(
      'lib/ui/widgets/sudoku_version_app_bar.dart',
    ).readAsStringSync();

    expect(
      appBar.contains(
        'Press this to open a drawer. Use the drawer menu to change animals and style.',
      ),
      isFalse,
      reason: 'Menu tooltip must be localized via UiStrings.',
    );
    expect(
      appBar.contains(
        'Press once to turn the background music off, or, twice, in quick succession to turn it on. To play a different background tune use < or >.',
      ),
      isFalse,
      reason: 'Music controls tooltip must be localized via UiStrings.',
    );
  });

  test('ActionBar does not hardcode New chip label', () {
    final actionBar = File('lib/ui/widgets/action_bar.dart').readAsStringSync();

    expect(
      actionBar.contains("Text('New')"),
      isFalse,
      reason: 'New chip label must come from ARB via UiStrings.',
    );
  });
}
