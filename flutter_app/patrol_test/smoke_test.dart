import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:flutter_app/main.dart' as app;

Future<void> _dismissInfoSheetIfVisible(PatrolIntegrationTester $) async {
  for (var i = 0; i < 3; i += 1) {
    final gotIt = $('Got it');
    if (gotIt.evaluate().isEmpty) {
      return;
    }
    await gotIt.tap();
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
    final hasUndo = $('Undo').evaluate().isNotEmpty;
    final hasNotes = $('Notes').evaluate().isNotEmpty;
    if (hasUndo && hasNotes) {
      return;
    }
    await $.pump(const Duration(milliseconds: 250));
  }
  throw StateError('Board controls did not become available in time.');
}

Future<void> _launchGame(PatrolIntegrationTester $) async {
  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 10; i += 1) {
    if ($('Undo').evaluate().isNotEmpty) {
      await _stabilizeBoard($);
      return;
    }

    if ($('Play').evaluate().isNotEmpty) {
      await $('Play').tap();
      await _stabilizeBoard($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  app.main();
  await $.pump(const Duration(milliseconds: 500));

  for (var i = 0; i < 20; i += 1) {
    if ($('Undo').evaluate().isNotEmpty) {
      await _stabilizeBoard($);
      return;
    }

    if ($('Play').evaluate().isNotEmpty) {
      await $('Play').tap();
      await _stabilizeBoard($);
      return;
    }

    await $.pump(const Duration(milliseconds: 500));
  }

  throw StateError('Neither the start screen nor the board became visible.');
}

Future<void> _openDrawer(PatrolIntegrationTester $) async {
  await _dismissInfoSheetIfVisible($);
  await $.tester.dragFrom(const Offset(4, 140), const Offset(320, 0));
  await $.pump(const Duration(milliseconds: 400));
  await $('SuDoKu Playtime').waitUntilVisible();
}

void main() {
  patrolTest('launches a new game from the start screen', ($) async {
    await _launchGame($);

    expect($('Undo'), findsOneWidget);
  });

  patrolTest('opens Help from top controls chip', ($) async {
    await _launchGame($);

    await _dismissInfoSheetIfVisible($);
    await $(find.byKey(const ValueKey<String>('top-controls-help-chip'))).tap();
    await $(find.byType(AlertDialog)).waitUntilVisible();
    final okInDialog = $(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('OK')),
    );
    await okInDialog.waitUntilVisible();

    expect(okInDialog, findsOneWidget);
    await okInDialog.tap();
  });

  patrolTest('shows drawer sections', ($) async {
    await _launchGame($);
    await _openDrawer($);

    await $('Puzzle Style').waitUntilVisible();
    await $('Audio').waitUntilVisible();
    await $('Version').waitUntilVisible();
    await $('Restore Purchases').waitUntilVisible();

    expect($('Puzzle Style'), findsWidgets);
    expect($('Audio'), findsWidgets);
    expect($('Version'), findsWidgets);
    expect($('Restore Purchases'), findsWidgets);
  });

  patrolTest('shows main action bar controls', ($) async {
    await _launchGame($);

    expect($('Notes'), findsOneWidget);
    expect($('Undo'), findsOneWidget);
    expect($('Clear'), findsOneWidget);
    expect(
      $(find.byKey(const ValueKey<String>('content-new-game-chip'))),
      findsOneWidget,
    );
  });
}
