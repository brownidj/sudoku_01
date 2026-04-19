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
    await $.pumpAndSettle();
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
  await $('Undo').waitUntilVisible();
}

Future<void> _launchGame(PatrolIntegrationTester $) async {
  await $.pumpAndSettle();

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
  await $.pumpAndSettle();

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
  await $.pumpAndSettle();
  await $('ZuDoKu+').waitUntilVisible();
}

void main() {
  patrolTest('launches a new game from the start screen', ($) async {
    await _launchGame($);

    expect($('Undo'), findsOneWidget);
  });

  patrolTest('opens Help from the app bar chip', ($) async {
    await _launchGame($);

    await _dismissInfoSheetIfVisible($);
    await $(find.byKey(const ValueKey<String>('appbar-help-chip'))).tap();
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

    await $('Animals').waitUntilVisible();
    await $('Puzzle Style').waitUntilVisible();
    await $('Audio').waitUntilVisible();

    expect($('Animals'), findsWidgets);
    expect($('Puzzle Style'), findsWidgets);
    expect($('Audio'), findsWidgets);
  });

  patrolTest('shows main action bar controls', ($) async {
    await _launchGame($);

    expect($('Notes'), findsOneWidget);
    expect($('Undo'), findsOneWidget);
    expect($('Clear'), findsOneWidget);
    expect($('Solution'), findsOneWidget);
  });
}
