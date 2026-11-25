import 'package:flutter/material.dart';
import 'package:flutter_app/ui/themes/downloadable_themes_screen.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer_sections.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloadable_themes_test_support.dart';
import 'support/sudoku_drawer_test_support.dart';

void main() {
  late ThemeStoreFixture fixture;
  setUp(() => fixture = ThemeStoreFixture());
  tearDown(() => fixture.purchases.events.close());

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DownloadableThemesScreen(
          createController: () async => fixture.controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    if (target.evaluate().isEmpty) {
      await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        target,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'drawer entry is below Full Version and above About without debug tools',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SudokuDrawer(
            state: drawerState(),
            onAnimalStyleChanged: (_) {},
            onStyleChanged: (_) {},
            showDebugTools: false,
            onDownloadableThemesSelected: () => opened = true,
          ),
        ),
      );
      final list = tester.widget<ListView>(find.byType(ListView));
      final children =
          (list.childrenDelegate as SliverChildListDelegate).children;
      final premium = children.indexWhere(
        (widget) => widget is SudokuDrawerPremiumSection,
      );
      final about = children.indexWhere(
        (widget) => widget is SudokuDrawerAboutSection,
      );
      final themes = children.indexWhere(
        (widget) => widget.key == const ValueKey('drawer-downloadable-themes'),
      );
      expect(themes, premium + 1);
      expect(about, themes + 1);
      await tap(tester, 'drawer-downloadable-themes');
      expect(opened, isTrue);
    },
  );

  testWidgets(
    'shows each separate theme and localized store price with unavailable content disabled',
    (tester) async {
      fixture.pilots['planets']!.published = false;
      fixture.pilots['buttons']!.published = false;
      await mount(tester);
      expect(find.text('Marine Life'), findsOneWidget);
      expect(find.text('Planets'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('buy-theme-marine')),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('buy-theme-planets')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text(r'Buy $3.99'), findsOneWidget);
      expect(find.textContaining('separate one-time purchase'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Antique Buttons'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Antique Buttons'), findsOneWidget);
    },
  );

  testWidgets(
    'purchase then download enables Use in puzzle; failed download offers retry',
    (tester) async {
      await mount(tester);
      await tap(tester, 'buy-theme-marine');
      expect(fixture.purchases.bought, ['theme_marine']);
      fixture.pilots['marine']!.failDownload = true;
      await tap(tester, 'download-theme-marine');
      expect(find.text('Retry download'), findsOneWidget);
      fixture.pilots['marine']!.failDownload = false;
      await tap(tester, 'download-theme-marine');
      expect(find.byKey(const ValueKey('use-theme-marine')), findsOneWidget);
      expect(fixture.purchases.bought, hasLength(1));
    },
  );

  testWidgets('Use in puzzle returns the installed theme to the caller', (
    tester,
  ) async {
    fixture.purchases.owned.add('theme_marine');
    fixture.pilots['marine']!.installed = fixture.pilots['marine']!.definition;
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              selected = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => DownloadableThemesScreen(
                    createController: () async => fixture.controller,
                  ),
                ),
              );
            },
            child: const Text('Open store'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open store'));
    await tester.pumpAndSettle();
    await tap(tester, 'use-theme-marine');
    expect(selected, 'marine');
    expect(find.text('Open store'), findsOneWidget);
  });

  testWidgets(
    'restore enables only purchased theme download and removal keeps purchase',
    (tester) async {
      fixture.purchases.owned.add('theme_marine');
      fixture.pilots['marine']!.installed =
          fixture.pilots['marine']!.definition;
      await mount(tester);
      await tap(tester, 'restore-theme-purchases');
      expect(fixture.purchases.restores, 1);
      await tap(tester, 'remove-theme-marine');
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('download-theme-marine')),
        findsOneWidget,
      );
      expect(fixture.controller.themes['marine']!.owned, isTrue);
      expect(fixture.controller.themes['planets']!.owned, isFalse);
    },
  );
}
