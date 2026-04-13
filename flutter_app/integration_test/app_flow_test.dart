import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/game_session_codec.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/main.dart' as app;

const _menuTooltip =
    'Press this to open a drawer. Use the drawer menu to change animals and style.';
const _correctionsTooltipPrefix = 'In this mode you have ';
const _undoTooltip =
    'Use Undo to step back through the selections you made previously. '
    'Undo clears each previous selection, one at a time. '
    'You can also do this if you run out of Corrections';
const _helpSnippet =
    'Long-press "Corrections" on the board for a quick explanation.';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch and play show the board controls', (tester) async {
    await _resetPreferences();
    await _launchApp(tester);

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);

    await _startGameFromLaunch(tester, buttonLabel: 'Play');

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Solution'), findsOneWidget);
    expect(find.textContaining('Corrections:'), findsOneWidget);
  });

  testWidgets('drawer and help are reachable', (tester) async {
    await _resetPreferences();
    await _launchApp(tester);
    await _startGameFromLaunch(tester, buttonLabel: 'Play');

    await tester.longPress(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text(_menuTooltip), findsOneWidget);

    await _openDrawer(tester);
    expect(find.text('Puzzle Solution Mode'), findsNothing);
    expect(find.text('Difficulty'), findsNothing);
    expect(find.text('Help'), findsOneWidget);

    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Help'), findsWidgets);
    expect(find.textContaining(_helpSnippet), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('board-puzzle-mode-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('board-difficulty-dropdown')),
      findsOneWidget,
    );
  });

  testWidgets('board tooltips are reachable', (tester) async {
    await _resetPreferences();
    await _launchApp(tester);
    await _startGameFromLaunch(tester, buttonLabel: 'Play');

    await tester.longPress(find.textContaining('Corrections:'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_correctionsTooltipPrefix), findsOneWidget);

    await tester.longPress(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text(_undoTooltip), findsOneWidget);
  });

  testWidgets('resume opens the saved session', (tester) async {
    await _resetPreferences();
    await _seedSavedSession(tokensLeft: 1);
    await _launchApp(tester);

    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);

    await _startGameFromLaunch(tester, buttonLabel: 'Resume');
    expect(find.text('Corrections: 1'), findsOneWidget);
  });

  testWidgets('new game ignores the saved correction count', (tester) async {
    await _resetPreferences();
    await _seedSavedSession(tokensLeft: 1);
    await _launchApp(tester);

    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);

    await _startGameFromLaunch(tester, buttonLabel: 'New game');
    expect(find.text('Corrections: 3'), findsOneWidget);
  });
}

Future<void> _launchApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1400));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
  await app.main();
  await tester.pumpAndSettle();
  await _pumpUntilVisible(
    tester,
    find.text('Play'),
    alternate: find.text('Resume'),
  );
}

Future<void> _startGameFromLaunch(
  WidgetTester tester, {
  required String buttonLabel,
}) async {
  await tester.tap(find.text(buttonLabel));
  await tester.pumpAndSettle();
  await _pumpUntilVisible(tester, find.text('Notes'));
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await _pumpUntilVisible(tester, find.text('Help'));
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder primary, {
  Finder? alternate,
  Duration step = const Duration(milliseconds: 250),
  int maxSteps = 40,
}) async {
  for (var i = 0; i < maxSteps; i += 1) {
    if (primary.evaluate().isNotEmpty) {
      return;
    }
    if (alternate != null && alternate.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(step);
  }
  throw StateError('Expected finder did not appear.');
}

Future<void> _resetPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> _seedSavedSession({required int tokensLeft}) async {
  final prefs = await SharedPreferences.getInstance();
  final codec = const GameSessionCodec();
  final board = Board.empty();
  final history = History.initial(GameState(board: board));
  const settings = SettingsState(
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'cute',
    puzzleMode: 'multi',
  );
  final correctionState = CorrectionState(
    tokensLeft: tokensLeft,
    currentMoveId: 0,
    checkpoints: [CorrectionCheckpoint(history: history, moveId: 0)],
    revertedCells: const {},
    pendingPromptCoord: null,
  );

  final payload = jsonEncode(<String, dynamic>{
    'version': GameSessionService.sessionVersion,
    'board': codec.boardToJson(board),
    'initialGrid': codec.gridToJson(
      List<List<int?>>.generate(
        9,
        (_) => List<int?>.filled(9, null, growable: false),
        growable: false,
      ),
    ),
    'selected': null,
    'gameOver': false,
    'debugScenarioLabel': null,
    'settings': <String, dynamic>{
      'notesMode': settings.notesMode,
      'difficulty': settings.difficulty,
      'canChangeDifficulty': settings.canChangeDifficulty,
      'canChangePuzzleMode': settings.canChangePuzzleMode,
      'styleName': settings.styleName,
      'contentMode': settings.contentMode,
      'animalStyle': settings.animalStyle,
      'puzzleMode': settings.puzzleMode,
    },
    'corrections': codec.correctionStateToJson(correctionState),
  });

  await prefs.setString(PreferencesStore.keyGameSession, payload);
}
