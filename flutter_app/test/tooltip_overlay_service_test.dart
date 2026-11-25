import 'package:flutter/material.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TooltipOverlayService overlay;
  late BuildContext context;

  setUp(() => overlay = TooltipOverlayService());
  tearDown(() => overlay.dispose());

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void show(String name, {bool image = true}) => overlay.show(
    context: context,
    globalPosition: const Offset(10, 10),
    text: name,
    imageAssetPath: image ? 'assets/images/butterflies/1_monarch.png' : null,
  );

  testWidgets('image and readable name fit a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    show('A butterfly with a long name');
    await tester.pump();
    final preview = find.byKey(const ValueKey('tile-preview-overlay'));
    expect(find.text('A butterfly with a long name'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final bounds = tester.getRect(preview);
    expect(bounds.left, greaterThanOrEqualTo(8));
    expect(bounds.top, greaterThanOrEqualTo(8));
    expect(bounds.right, lessThanOrEqualTo(272));
    expect(bounds.bottom, lessThanOrEqualTo(392));
    expect(tester.takeException(), isNull);
    overlay.dispose();
    await tester.pump();
  });

  testWidgets(
    'replacing preview gives the new image and name a full lifetime',
    (tester) async {
      await mount(tester);
      show('First');
      await tester.pump(const Duration(seconds: 3));
      show('Second');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Second'), findsNothing);
    },
  );

  testWidgets('text-only hints still display and disposal cancels dismissal', (
    tester,
  ) async {
    await mount(tester);
    show('Hint', image: false);
    await tester.pump();
    expect(find.text('Hint'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    overlay.dispose();
    await tester.pump();
    expect(find.text('Hint'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
