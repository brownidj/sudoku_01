import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'release_checklist_helpers.dart';

void main() {
  patrolTest('locked difficulties route to the premium explainer', ($) async {
    await launchGame($);

    await assertPremiumSheetForDifficulty($, 'MUCH HARDER');
    await assertPremiumSheetForDifficulty($, 'NIGH IMPOSSIBLE');
    expect($(find.text('EASY')), findsOneWidget);
  });
}
