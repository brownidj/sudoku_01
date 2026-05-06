import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_drawer_test_support.dart';

void main() {
  testWidgets('shows temporary debug scenario controls in debug builds', (
    WidgetTester tester,
  ) async {
    var correctionTapped = false;
    var exhaustedTapped = false;
    var resetEntitlementTapped = false;

    await tester.pumpWidget(
      drawerHarness(
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
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('Load Correction Scenario'), findsOneWidget);
    expect(find.text('Load Exhausted Correction Scenario'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Reset Full Version (Debug)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Reset Full Version (Debug)'), findsOneWidget);
    expect(find.text('Help'), findsNothing);

    await tester.tap(find.text('Load Correction Scenario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load Exhausted Correction Scenario'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Reset Full Version (Debug)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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
      drawerHarness(
        onRestorePurchasesSelected: () {
          restoreTapped = true;
        },
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
    await tester.pumpWidget(drawerHarness(premiumActive: true));

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
