import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';

UiState _state() {
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
    gameOver: false,
    correctionsLeft: 5,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
  );
}

void main() {
  testWidgets('audio row toggles between on and off', (
    WidgetTester tester,
  ) async {
    bool? audioEnabled;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
          audioEnabled: true,
          onAudioEnabledChanged: (enabled) {
            audioEnabled = enabled;
          },
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('On'), findsOneWidget);

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(audioEnabled, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
          audioEnabled: false,
          onAudioEnabledChanged: (enabled) {
            audioEnabled = enabled;
          },
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Off'), findsOneWidget);
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(audioEnabled, isTrue);
  });

  testWidgets('shows temporary debug scenario controls in debug builds', (
    WidgetTester tester,
  ) async {
    var correctionTapped = false;
    var exhaustedTapped = false;
    var helpTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
          onHelpPressed: () {
            helpTapped = true;
          },
          onLoadCorrectionScenario: () {
            correctionTapped = true;
          },
          onLoadExhaustedCorrectionScenario: () {
            exhaustedTapped = true;
          },
          showDebugTools: true,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Load Correction Scenario'), findsOneWidget);
    expect(find.text('Load Exhausted Correction Scenario'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load Correction Scenario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load Exhausted Correction Scenario'));
    await tester.pumpAndSettle();

    expect(helpTapped, isTrue);
    expect(correctionTapped, isTrue);
    expect(exhaustedTapped, isTrue);
  });
}
