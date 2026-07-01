import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'release_checklist_helpers.dart';

void main() {
  patrolTest('free-state drawer and locked premium entries are visible', (
    $,
  ) async {
    await launchGame($);
    await openDrawer($);

    expect(byKey($, 'drawer-premium-status'), findsOneWidget);
    expect($(find.text('Free')), findsOneWidget);
    expect(byKey($, 'drawer-locked-progress-tracker'), findsOneWidget);
    expect(byKey($, 'drawer-locked-extra-themes'), findsOneWidget);
    expect(byKey($, 'drawer-locked-extra-sounds'), findsOneWidget);
    expect(byKey($, 'drawer-unlock-premium'), findsOneWidget);
    expect(byKey($, 'drawer-restore-purchases'), findsOneWidget);
  });
}
