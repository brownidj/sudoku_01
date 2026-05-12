import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/ui/launch_screen.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

import 'support/sudoku_controller_test_support.dart';

const SettingsState _defaultSettings = SettingsState(
  notesMode: false,
  difficulty: 'easy',
  canChangeDifficulty: true,
  canChangePuzzleMode: false,
  styleName: 'Modern',
  contentMode: 'numbers',
  animalStyle: 'simple',
  puzzleMode: 'unique',
);

Future<void> _pumpWithLocale(
  WidgetTester tester, {
  required Locale locale,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('launch screen renders across supported locales on small width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
    );
    await controller.ready;

    const locales = <Locale>[
      Locale('en'),
      Locale('ja'),
      Locale('de'),
      Locale('fr'),
      Locale('it'),
      Locale('pt'),
      Locale('hi'),
      Locale('es'),
    ];

    for (final locale in locales) {
      await _pumpWithLocale(
        tester,
        locale: locale,
        child: LaunchScreen(controller: controller),
      );
      expect(find.byType(LaunchScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('japanese locale localizes help dialog and progress sheet', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(completedPuzzles: 7),
      gameService: FakeGameService(),
      settingsController: FakeSettingsController(_defaultSettings),
    );
    await controller.ready;

    await _pumpWithLocale(
      tester,
      locale: const Locale('ja'),
      child: SudokuScreen(controller: controller),
    );

    await tester.tap(find.byKey(const ValueKey<String>('top-controls-help-chip')));
    await tester.pumpAndSettle();
    expect(find.text('ヘルプ'), findsWidgets);
    expect(find.textContaining('長押し'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    controller.onShowSolution();
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('top-controls-progress-chip')),
    );
    await tester.pumpAndSettle();

    expect(find.text('進行状況'), findsOneWidget);
    expect(find.textContaining('完了したパズル: 7'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
