import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/widgets/sudoku_version_app_bar.dart';

Widget _harness({required bool showMusicControls, bool audioEnabled = true}) {
  return MaterialApp(
    home: Scaffold(
      appBar: SudokuVersionAppBar(
        onVersionTapped: () {},
        onVersionLongPressed: () {},
        audioEnabled: audioEnabled,
        showMusicControls: showMusicControls,
        backgroundMusicEnabled: true,
        onMusicControlSingleTap: () {},
        onMusicControlDoubleTap: () {},
        onPreviousTrackTapped: () {},
        onNextTrackTapped: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows music controls when enabled for theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(showMusicControls: true));

    expect(find.byKey(const ValueKey<String>('appbar-music-prev-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('appbar-music-note-text')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('appbar-music-next-button')), findsOneWidget);
  });

  testWidgets('hides music controls when not enabled for theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(showMusicControls: false));

    expect(find.byKey(const ValueKey<String>('appbar-music-prev-button')), findsNothing);
    expect(find.byKey(const ValueKey<String>('appbar-music-note-text')), findsNothing);
    expect(find.byKey(const ValueKey<String>('appbar-music-next-button')), findsNothing);
  });
}
