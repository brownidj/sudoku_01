import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:flutter_app/main.dart' as app;

Future<void> _launchGame(PatrolIntegrationTester $) async {
  app.main();
  await $.pumpAndSettle();
  await $('Play').tap();
  await $('Notes').waitUntilVisible();
}

Future<void> _openDrawer(PatrolIntegrationTester $) async {
  await $(Icons.menu).tap();
}

void main() {
  patrolTest('launches a new game from the start screen', ($) async {
    await _launchGame($);

    expect($('Notes'), findsOneWidget);
  });

  patrolTest('opens Help from the drawer', ($) async {
    await _launchGame($);
    await _openDrawer($);

    await $('Help').tap();
    await $('OK').waitUntilVisible();

    expect($('OK'), findsOneWidget);
    await $('OK').tap();
  });

  patrolTest('shows drawer sections', ($) async {
    await _launchGame($);
    await _openDrawer($);

    await $('Puzzle Solution Mode').waitUntilVisible();
    await $('Difficulty').waitUntilVisible();
    await $('Help').waitUntilVisible();

    expect($('Puzzle Solution Mode'), findsOneWidget);
    expect($('Difficulty'), findsOneWidget);
    expect($('Help'), findsOneWidget);
  });

  patrolTest('shows main action bar controls', ($) async {
    await _launchGame($);

    expect($('Notes'), findsOneWidget);
    expect($('Undo'), findsOneWidget);
    expect($('Clear'), findsOneWidget);
    expect($('Solution'), findsOneWidget);
  });
}
