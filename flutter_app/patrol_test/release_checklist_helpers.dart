import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:flutter_app/main.dart' as app;

PatrolFinder byKey(PatrolIntegrationTester $, String key) =>
    $(find.byKey(ValueKey<String>(key)));

Future<void> dismissInfoSheetIfVisible(PatrolIntegrationTester $) async {
  for (var i = 0; i < 3; i += 1) {
    final dismiss = byKey($, 'info-sheet-dismiss-button');
    if (dismiss.evaluate().isEmpty) {
      return;
    }
    await dismiss.tap();
    await $.pump(const Duration(milliseconds: 300));
  }
}

Future<void> waitForBoardControls(PatrolIntegrationTester $) async {
  for (var i = 0; i < 40; i += 1) {
    await dismissInfoSheetIfVisible($);
    final hasUndo = byKey($, 'action-undo-button').evaluate().isNotEmpty;
    final hasNotes = byKey($, 'action-notes-button').evaluate().isNotEmpty;
    if (hasUndo && hasNotes) {
      return;
    }
    await $.pump(const Duration(milliseconds: 250));
  }
  throw StateError('Board controls did not become available in time.');
}

Future<void> launchGame(PatrolIntegrationTester $) async {
  Future<bool> tryLaunchFromStartScreen() async {
    final play = byKey($, 'launch-play-button');
    if (play.evaluate().isNotEmpty) {
      await play.tap();
      return true;
    }
    final resume = byKey($, 'launch-resume-button');
    if (resume.evaluate().isNotEmpty) {
      await resume.tap();
      return true;
    }
    final newGame = byKey($, 'launch-new-game-button');
    if (newGame.evaluate().isNotEmpty) {
      await newGame.tap();
      return true;
    }
    return false;
  }

  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 10; i += 1) {
    if (byKey($, 'action-undo-button').evaluate().isNotEmpty) {
      await waitForBoardControls($);
      return;
    }

    if (await tryLaunchFromStartScreen()) {
      await waitForBoardControls($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  app.main();
  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 20; i += 1) {
    if (byKey($, 'action-undo-button').evaluate().isNotEmpty) {
      await waitForBoardControls($);
      return;
    }

    if (await tryLaunchFromStartScreen()) {
      await waitForBoardControls($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  throw StateError('Neither the start screen nor the board became visible.');
}

Future<void> openDrawer(PatrolIntegrationTester $) async {
  await dismissInfoSheetIfVisible($);
  await byKey($, 'appbar-menu-button').tap();
  for (var i = 0; i < 20; i += 1) {
    await $.pump(const Duration(milliseconds: 200));
    if (byKey($, 'drawer-premium-status').evaluate().isNotEmpty) {
      return;
    }
  }
  throw StateError(
    'Drawer premium status did not appear after opening the drawer.',
  );
}

Future<void> tapCurrentContentMode(PatrolIntegrationTester $) async {
  const labels = <String>[
    'Animals (easy)',
    'Instruments (tricky)',
    'Numbers (old-school)',
  ];
  for (final label in labels) {
    final finder = $(find.text(label));
    if (finder.evaluate().isNotEmpty) {
      await finder.tap();
      await $.pump(const Duration(milliseconds: 300));
      return;
    }
  }
  throw StateError('Could not find current free content mode label.');
}

Future<void> assertPremiumSheetForDifficulty(
  PatrolIntegrationTester $,
  String difficultyLabel,
) async {
  await byKey($, 'board-difficulty-dropdown').tap();
  await $.pump(const Duration(milliseconds: 300));
  await $(find.text(difficultyLabel).hitTestable().last).tap();
  await byKey($, 'premium-sheet-title').waitUntilVisible();
  expect(byKey($, 'premium-sheet-title'), findsOneWidget);
  await byKey($, 'premium-sheet-dismiss-button').tap();
  await $.pump(const Duration(milliseconds: 300));
}

Future<void> assertPremiumSheetForTheme(
  PatrolIntegrationTester $,
  String themeLabel,
) async {
  await tapCurrentContentMode($);
  await $(find.text(themeLabel).last).tap();
  await byKey($, 'premium-sheet-title').waitUntilVisible();
  expect(byKey($, 'premium-sheet-title'), findsOneWidget);
  await byKey($, 'premium-sheet-dismiss-button').tap();
  await $.pump(const Duration(milliseconds: 300));
}
