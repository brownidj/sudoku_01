import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';

UiState _state({bool premiumActive = false}) {
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
    entitlement: premiumActive ? Entitlement.premium : Entitlement.free,
    premiumActive: premiumActive,
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
    var resetEntitlementTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
          onLoadCorrectionScenario: () {
            correctionTapped = true;
          },
          onLoadExhaustedCorrectionScenario: () {
            exhaustedTapped = true;
          },
          onResetEntitlementToFreeSelected: () {
            resetEntitlementTapped = true;
          },
          showDebugTools: true,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Load Correction Scenario'), findsOneWidget);
    expect(find.text('Load Exhausted Correction Scenario'), findsOneWidget);
    expect(find.text('Reset Full Version (Debug)'), findsOneWidget);
    expect(find.text('Help'), findsNothing);

    await tester.tap(find.text('Load Correction Scenario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load Exhausted Correction Scenario'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reset Full Version (Debug)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset Full Version (Debug)'));
    await tester.pumpAndSettle();

    expect(correctionTapped, isTrue);
    expect(exhaustedTapped, isTrue);
    expect(resetEntitlementTapped, isTrue);
  });

  testWidgets('shows premium status and restore purchases action', (
    WidgetTester tester,
  ) async {
    var restoreTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
          onRestorePurchasesSelected: () {
            restoreTapped = true;
          },
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('drawer-premium-status')),
      findsOneWidget,
    );
    expect(find.text('Free'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('drawer-restore-purchases')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('drawer-restore-purchases')),
    );
    await tester.pumpAndSettle();
    expect(restoreTapped, isTrue);
  });

  testWidgets('shows full premium status and hides locked premium rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(premiumActive: true),
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('drawer-premium-status')),
      findsOneWidget,
    );
    expect(find.text('Full'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('drawer-restore-purchases')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('drawer-locked-progress-tracker')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('drawer-locked-extra-themes')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('drawer-locked-extra-sounds')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('drawer-unlock-premium')),
      findsNothing,
    );
  });
}
