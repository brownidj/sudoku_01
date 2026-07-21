import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';

import 'support/sudoku_board_area_test_support.dart';

void main() {
  testWidgets('premium metadata row caps idle time at sixty seconds', (
    WidgetTester tester,
  ) async {
    final activeStartedAt = DateTime.now().subtract(
      const Duration(seconds: 90),
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
                activeElapsedSeconds: 120,
                activeTimingStartedAt: activeStartedAt,
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

    expect(find.text('Time: 3:00'), findsOneWidget);
  });
}
