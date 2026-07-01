import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'support/sudoku_board_area_test_support.dart';

void main() {
  testWidgets('main metadata row shows corrections left and difficulty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(
                puzzleMode: 'unique',
                difficulty: 'hard',
                conflictHintsLeft: 2,
                correctionsLeft: 1,
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Hints:'), findsNothing);
    expect(find.text('Corrections: 1'), findsOneWidget);
    expect(find.text('MUCH HARDER'), findsOneWidget);
  });

  testWidgets('premium metadata row shows elapsed game time', (
    WidgetTester tester,
  ) async {
    final startedAt = DateTime.now().subtract(
      const Duration(minutes: 3, seconds: 4),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(
                premiumActive: true,
                puzzleStartedAt: startedAt,
                puzzleFinishedAt: startedAt.add(
                  const Duration(minutes: 3, seconds: 4),
                ),
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Time: 3:04'), findsOneWidget);
  });

  testWidgets('free metadata row hides elapsed game time', (
    WidgetTester tester,
  ) async {
    final startedAt = DateTime.now().subtract(
      const Duration(minutes: 3, seconds: 4),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(
                puzzleStartedAt: startedAt,
                puzzleFinishedAt: startedAt.add(
                  const Duration(minutes: 3, seconds: 4),
                ),
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Time:'), findsNothing);
  });

  testWidgets('long press on corrections label shows tooltip details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(
                puzzleMode: 'unique',
                difficulty: 'medium',
                correctionsLeft: 2,
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Corrections: 2'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You have 2 automatic corrections available for this puzzle. '
        'If an earlier move blocks your progress, you can use a correction to keep going. '
        'If you run out of corrections, use Undo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows debug scenario label when one is loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(
                debugScenarioLabel: 'Debug scenario: corrections exhausted',
              ),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Debug scenario: corrections exhausted'), findsOneWidget);
  });

  testWidgets('does not render inline start instruction banner', (
    WidgetTester tester,
  ) async {
    const message = 'To start, select a square you want to add an icon to.';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(selected: null),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: false,
              candidateDigits: const [],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );
    expect(find.text(message), findsNothing);
  });

  testWidgets('candidate long press does not show name toast', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 620,
            child: SudokuBoardArea(
              state: boardAreaState(contentMode: 'instruments'),
              style: styleModern,
              animalImages: const {},
              noteImagesBySize: const {},
              devicePixelRatio: 2.0,
              candidateVisible: true,
              candidateDigits: const [1],
              selectedNotes: const {},
              onDigitSelected: (_) {},
              onDigitLongPressed: null,
              onTapCell: (_) {},
              onLongPressCell: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('P'), findsOneWidget);
    await tester.longPress(find.text('P'));
    await tester.pumpAndSettle();

    expect(find.text('Piano'), findsNothing);
    expect(find.text('ape'), findsNothing);
  });
}
