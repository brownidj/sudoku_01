import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:flutter_app/main.dart' as app;

PatrolFinder _byKey(PatrolIntegrationTester $, String key) =>
    $(find.byKey(ValueKey<String>(key)));

Future<void> _dismissInfoSheetIfVisible(PatrolIntegrationTester $) async {
  for (var i = 0; i < 3; i += 1) {
    final dismiss = _byKey($, 'info-sheet-dismiss-button');
    if (dismiss.evaluate().isEmpty) {
      return;
    }
    await dismiss.tap();
    await $.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _stabilizeBoard(PatrolIntegrationTester $) async {
  await _waitForBoardControls($);
  for (var i = 0; i < 3; i += 1) {
    await $.pump(const Duration(milliseconds: 250));
    await _dismissInfoSheetIfVisible($);
  }
}

Future<void> _waitForBoardControls(PatrolIntegrationTester $) async {
  for (var i = 0; i < 40; i += 1) {
    await _dismissInfoSheetIfVisible($);
    final hasUndo = _byKey($, 'action-undo-button').evaluate().isNotEmpty;
    final hasNotes = _byKey($, 'action-notes-button').evaluate().isNotEmpty;
    if (hasUndo && hasNotes) {
      return;
    }
    await $.pump(const Duration(milliseconds: 250));
  }
  throw StateError('Board controls did not become available in time.');
}

Future<void> _launchGame(PatrolIntegrationTester $) async {
  Future<bool> tryLaunchFromStartScreen() async {
    final play = _byKey($, 'launch-play-button');
    if (play.evaluate().isNotEmpty) {
      await play.tap();
      return true;
    }
    final resume = _byKey($, 'launch-resume-button');
    if (resume.evaluate().isNotEmpty) {
      await resume.tap();
      return true;
    }
    final newGame = _byKey($, 'launch-new-game-button');
    if (newGame.evaluate().isNotEmpty) {
      await newGame.tap();
      return true;
    }
    return false;
  }

  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 10; i += 1) {
    if (_byKey($, 'action-undo-button').evaluate().isNotEmpty) {
      await _stabilizeBoard($);
      return;
    }

    if (await tryLaunchFromStartScreen()) {
      await _stabilizeBoard($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  app.main();
  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 20; i += 1) {
    if (_byKey($, 'action-undo-button').evaluate().isNotEmpty) {
      await _stabilizeBoard($);
      return;
    }

    if (await tryLaunchFromStartScreen()) {
      await _stabilizeBoard($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  throw StateError('Neither the start screen nor the board became visible.');
}

Future<void> _openDrawer(PatrolIntegrationTester $) async {
  await _dismissInfoSheetIfVisible($);
  await _byKey($, 'appbar-menu-button').tap();
  await $.pump(const Duration(milliseconds: 400));
  await _byKey($, 'drawer-premium-status').waitUntilVisible();
}

void main() {
  patrolTest('launches a new game from the start screen', ($) async {
    await _launchGame($);

    expect(_byKey($, 'action-undo-button'), findsOneWidget);
  });

  patrolTest('opens Help from top controls chip', ($) async {
    await _launchGame($);

    await _dismissInfoSheetIfVisible($);
    await $(find.byKey(const ValueKey<String>('top-controls-help-chip'))).tap();
    await $(find.byType(AlertDialog)).waitUntilVisible();
    final dismissButton = _byKey($, 'help-dialog-dismiss-button');
    await dismissButton.waitUntilVisible();
    expect(dismissButton, findsOneWidget);
    await dismissButton.tap();
  });

  patrolTest('shows drawer sections', ($) async {
    await _launchGame($);
    await _openDrawer($);

    await _byKey($, 'drawer-puzzle-style-section').waitUntilVisible();
    await _byKey($, 'drawer-audio-section').waitUntilVisible();
    await _byKey($, 'drawer-premium-status').waitUntilVisible();
    await _byKey($, 'drawer-restore-purchases').waitUntilVisible();

    expect(_byKey($, 'drawer-puzzle-style-section'), findsOneWidget);
    expect(_byKey($, 'drawer-audio-section'), findsOneWidget);
    expect(_byKey($, 'drawer-premium-status'), findsOneWidget);
    expect(_byKey($, 'drawer-restore-purchases'), findsOneWidget);
  });

  patrolTest('shows main action bar controls', ($) async {
    await _launchGame($);

    expect(_byKey($, 'action-notes-button'), findsOneWidget);
    expect(_byKey($, 'action-undo-button'), findsOneWidget);
    expect(_byKey($, 'action-clear-button'), findsOneWidget);
    expect(
      $(find.byKey(const ValueKey<String>('content-new-game-chip'))),
      findsOneWidget,
    );
  });
}
