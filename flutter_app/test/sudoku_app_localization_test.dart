import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/sudoku_app.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  tearDown(() {
    final dispatcher = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher;
    dispatcher.clearLocaleTestValue();
    dispatcher.clearLocalesTestValue();
  });

  testWidgets('uses Japanese locale when available', (tester) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.localesTestValue = const [Locale('ja')];

    await tester.pumpWidget(const SudokuApp());
    await tester.pumpAndSettle();

    expect(find.text('プレイ'), findsOneWidget);
  });

  testWidgets('uses French locale when available', (tester) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.localesTestValue = const [Locale('fr')];

    await tester.pumpWidget(const SudokuApp());
    await tester.pumpAndSettle();

    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('uses persisted in-app language choice when set', (tester) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.localesTestValue = const [Locale('ja')];
    final prefs = FakePreferencesStore(preferredLanguageCode: 'fr');
    final controller = SudokuController(preferencesStore: prefs);
    await controller.ready;

    await tester.pumpWidget(SudokuApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('resetting preferred language returns to system language', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.localesTestValue = const [Locale('ja')];
    final prefs = FakePreferencesStore(preferredLanguageCode: 'fr');
    final controller = SudokuController(preferencesStore: prefs);
    await controller.ready;

    await controller.onResetPreferredLanguageToSystem();
    await tester.pumpWidget(SudokuApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('プレイ'), findsOneWidget);
  });
}
