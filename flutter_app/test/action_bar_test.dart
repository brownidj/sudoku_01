import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';

UiState _state({bool canUndo = false, bool puzzleSolved = false}) {
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => List<CellVm>.generate(
      9,
      (c) => CellVm(
        coord: Coord(r, c),
        value: null,
        given: false,
        notes: const [],
        selected: false,
        conflicted: false,
        incorrect: false,
        solutionAdded: false,
        correct: false,
        reverted: false,
      ),
      growable: false,
    ),
    growable: false,
  );

  return UiState(
    board: BoardVm(cells: cells),
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: puzzleSolved,
    puzzleSolved: puzzleSolved,
    correctionsLeft: 5,
    canUndo: canUndo,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  testWidgets('Undo button shows tooltip text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Undo'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ActionBar));
    expect(find.text(UiStrings.tooltipUndo(context)), findsOneWidget);
  });

  testWidgets('New game dice shows tooltip text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    await tester.longPress(find.byKey(const ValueKey<String>('content-new-game-chip')));
    await tester.pumpAndSettle();

    expect(find.text('Press this to start a new game.'), findsOneWidget);
  });

  testWidgets('New game dice animation pauses after first move and resumes on victory', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
            onNewGamePressed: () {},
          ),
        ),
      ),
    );

    final pausedImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('content-new-game-chip')),
        matching: find.byType(Image),
      ),
    );
    final pausedProvider = pausedImage.image as AssetImage;
    expect(pausedProvider.assetName, 'assets/images/icons/dice-roll-still.png');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true, puzzleSolved: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
            onNewGamePressed: () {},
          ),
        ),
      ),
    );

    final resumedImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('content-new-game-chip')),
        matching: find.byType(Image),
      ),
    );
    final resumedProvider = resumedImage.image as AssetImage;
    expect(resumedProvider.assetName, 'assets/images/icons/dice-roll.gif');
  });

  testWidgets('narrow screens use icon-only labels for clear and undo', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionBar(
            state: _state(canUndo: true),
            onUndo: () {},
            onToggleNotesMode: () {},
            onClear: () {},
            onCheckOrSolution: () {},
          ),
        ),
      ),
    );

    expect(find.text('⌫'), findsOneWidget);
    expect(find.text('↶'), findsOneWidget);
    expect(find.text('Clear'), findsNothing);
    expect(find.text('Undo'), findsNothing);
  });
}
