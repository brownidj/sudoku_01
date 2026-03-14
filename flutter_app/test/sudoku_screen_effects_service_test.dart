import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_service.dart';

UiState _state({
  int correctionNoticeSerial = 0,
  String? correctionNoticeMessage,
}) {
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
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: correctionNoticeSerial,
    correctionNoticeMessage: correctionNoticeMessage,
  );
}

void main() {
  test('tracks correction prompt and notice scheduling', () {
    final service = SudokuScreenEffectsService();

    expect(service.shouldScheduleCorrectionPrompt(null), isFalse);
    expect(service.shouldScheduleCorrectionPrompt(const Coord(1, 1)), isTrue);
    expect(service.shouldScheduleCorrectionPrompt(const Coord(1, 1)), isFalse);

    expect(
      service.shouldScheduleCorrectionNotice(
        serial: 0,
        message: '1 tile(s) corrected.',
      ),
      isFalse,
    );
    expect(
      service.shouldScheduleCorrectionNotice(serial: 1, message: null),
      isFalse,
    );
    expect(
      service.shouldScheduleCorrectionNotice(
        serial: 1,
        message: '1 tile(s) corrected.',
      ),
      isTrue,
    );
  });

  testWidgets('shows correction notice once per serial', (tester) async {
    final service = SudokuScreenEffectsService();
    BuildContext? capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(capturedContext, isNotNull);

    service.showCorrectionNotice(
      capturedContext!,
      _state(
        correctionNoticeSerial: 1,
        correctionNoticeMessage: '2 tile(s) corrected.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 tile(s) corrected.'), findsOneWidget);
    expect(
      service.shouldScheduleCorrectionNotice(
        serial: 1,
        message: '2 tile(s) corrected.',
      ),
      isFalse,
    );
  });
}
