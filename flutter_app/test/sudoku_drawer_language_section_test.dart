import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer_language_section.dart';

Future<void> _pumpLanguageSection(
  WidgetTester tester, {
  required Locale locale,
  String? selectedLanguageCode,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SudokuDrawerLanguageSection(
          sectionPadding: const EdgeInsets.symmetric(horizontal: 16),
          compactDensity: const VisualDensity(horizontal: 0, vertical: -4),
          selectedLanguageCode: selectedLanguageCode,
          onLanguageChanged: (_) {},
          showExpandedMenuForScreenshot: true,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('language choices are shown in their own languages', (
    WidgetTester tester,
  ) async {
    await _pumpLanguageSection(
      tester,
      locale: const Locale('de'),
      selectedLanguageCode: 'de',
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('Deutsch'), findsWidgets);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
  });

  testWidgets('language section does not show reset-to-system action', (
    WidgetTester tester,
  ) async {
    await _pumpLanguageSection(
      tester,
      locale: const Locale('en'),
      selectedLanguageCode: 'en',
    );

    expect(
      find.byKey(const ValueKey<String>('drawer-language-reset-button')),
      findsNothing,
    );
    expect(find.text('Reset to System Language'), findsNothing);
  });
}
