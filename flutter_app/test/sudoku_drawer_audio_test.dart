import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_drawer_test_support.dart';

void main() {
  testWidgets('audio row toggles between on and off', (WidgetTester tester) async {
    bool? audioEnabled;

    await tester.pumpWidget(
      drawerHarness(
        audioEnabled: true,
        onAudioEnabledChanged: (enabled) {
          audioEnabled = enabled;
        },
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Audio'), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Audio'), matching: find.byType(ListTile)),
        matching: find.text('On'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(audioEnabled, isFalse);

    await tester.pumpWidget(
      drawerHarness(
        audioEnabled: false,
        onAudioEnabledChanged: (enabled) {
          audioEnabled = enabled;
        },
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Audio'), matching: find.byType(ListTile)),
        matching: find.text('Off'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(audioEnabled, isTrue);
  });

  testWidgets('audio section shows ordered rows, strapline, and volume state', (
    WidgetTester tester,
  ) async {
    double? volumeChanged;
    bool? backgroundMusicChanged;

    await tester.pumpWidget(
      drawerHarness(
        contentMode: 'butterflies',
        audioEnabled: true,
        backgroundMusicEnabled: true,
        onAudioEnabledChanged: (_) {},
        onBackgroundMusicEnabledChanged: (enabled) {
          backgroundMusicChanged = enabled;
        },
        audioVolume: 0.5,
        onAudioVolumeChanged: (value) {
          volumeChanged = value;
        },
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final audioY = tester.getTopLeft(find.text('Audio')).dy;
    final bgMusicY = tester.getTopLeft(find.text('Background music')).dy;
    final volumeY = tester.getTopLeft(find.text('Volume')).dy;
    expect(audioY, lessThan(bgMusicY));
    expect(bgMusicY, lessThan(volumeY));

    final straplineFinder = find.text('Sounds for SuDoKu lovers');
    expect(straplineFinder, findsOneWidget);
    final straplineText = tester.widget<Text>(straplineFinder);
    expect(straplineText.style?.fontStyle, FontStyle.italic);

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    final enabledSlider = tester.widget<Slider>(sliderFinder);
    expect(enabledSlider.onChanged, isNotNull);

    await tester.tap(find.text('Background music'));
    await tester.pumpAndSettle();
    expect(backgroundMusicChanged, isFalse);

    await tester.drag(sliderFinder, const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(volumeChanged, isNotNull);

    await tester.pumpWidget(
      drawerHarness(
        contentMode: 'butterflies',
        audioEnabled: false,
        backgroundMusicEnabled: false,
        onAudioEnabledChanged: (_) {},
        onBackgroundMusicEnabledChanged: (_) {},
        audioVolume: 0.5,
        onAudioVolumeChanged: (_) {},
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final disabledSlider = tester.widget<Slider>(find.byType(Slider));
    expect(disabledSlider.onChanged, isNull);
  });

  testWidgets('background music row is hidden outside butterflies theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      drawerHarness(
        contentMode: 'numbers',
        audioEnabled: true,
        backgroundMusicEnabled: true,
        onAudioEnabledChanged: (_) {},
        onBackgroundMusicEnabledChanged: (_) {},
        audioVolume: 0.5,
        onAudioVolumeChanged: (_) {},
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Background music'), findsNothing);
    expect(find.text('Sounds for SuDoKu lovers'), findsNothing);
    expect(find.text('Volume'), findsOneWidget);
  });

  testWidgets('background music row is shown for opera theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      drawerHarness(
        contentMode: 'old_opera',
        audioEnabled: true,
        backgroundMusicEnabled: true,
        onAudioEnabledChanged: (_) {},
        onBackgroundMusicEnabledChanged: (_) {},
        audioVolume: 0.5,
        onAudioVolumeChanged: (_) {},
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Background music'), findsOneWidget);
    expect(find.text('Sounds for SuDoKu lovers'), findsOneWidget);
  });
}
