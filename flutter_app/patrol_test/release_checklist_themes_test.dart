import 'package:patrol/patrol.dart';

import 'release_checklist_helpers.dart';

void main() {
  patrolTest('locked premium themes route to the premium explainer', ($) async {
    await launchGame($);

    await assertPremiumSheetForTheme($, 'Butterflies (pretty!)');
    await assertPremiumSheetForTheme($, 'Shells (new!)');
    await assertPremiumSheetForTheme($, 'Opera (unreal!)');
  });
}
