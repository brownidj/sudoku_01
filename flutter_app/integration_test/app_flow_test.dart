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
const _correctionsTooltipPrefix = 'automatic corrections available';
const _undoTooltip =
    'Use Undo to step back through the selections you made previously. '
    'Undo clears each previous selection, one at a time. '
    'You can also do this if you run out of Corrections';
const _helpSnippet = 'holding your finger';

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
    await _dismissInfoSheetIfVisible(tester);

    await tester.longPress(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text(_menuTooltip), findsOneWidget);

    await _openDrawer(tester);
    expect(find.text('Puzzle Solution Mode'), findsNothing);
    expect(find.text('Difficulty'), findsNothing);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Help')),
      findsNothing,
    );

    Navigator.of(tester.element(find.byType(Scaffold))).maybePop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('appbar-help-chip')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
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
    await _dismissInfoSheetIfVisible(tester);

    await tester.longPress(find.textContaining('Corrections:'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_correctionsTooltipPrefix), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    await tester.longPress(find.widgetWithText(OutlinedButton, 'Undo'));
    await tester.pumpAndSettle();
    expect(find.text(_undoTooltip), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
  });

  testWidgets('content mode switch works across all options', (tester) async {
    await _resetPreferences();
    await _launchApp(tester);
    await _startGameFromLaunch(tester, buttonLabel: 'Play');
    await _dismissInfoSheetIfVisible(tester);

    await _selectContentMode(tester, label: 'Instruments');
    expect(_contentModeDropdown(tester).value, 'instruments');

    await _selectContentMode(tester, label: 'Numbers');
    expect(_contentModeDropdown(tester).value, 'numbers');

    await _selectContentMode(tester, label: 'Animals');
    expect(_contentModeDropdown(tester).value, 'animals');

    await _selectContentMode(tester, label: 'Instruments');
    expect(_contentModeDropdown(tester).value, 'instruments');
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
  await _pumpUntilVisible(tester, find.text('ZuDoKu+'));
}

Future<void> _dismissInfoSheetIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got it');
  if (gotIt.evaluate().isEmpty) {
    return;
  }
  await tester.tap(gotIt.first);
  await tester.pumpAndSettle();
}

DropdownButton<String> _contentModeDropdown(WidgetTester tester) {
  return tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>).first,
  );
}

Future<void> _selectContentMode(
  WidgetTester tester, {
  required String label,
}) async {
  await tester.tap(find.byType(DropdownButton<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
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
