import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test(
    'purchase stream update unlocks premium and persists entitlement',
    () async {
      final fakePrefs = FakePreferencesStore(entitlement: Entitlement.free);
      final fakeBilling = FakeBillingService();
      final controller = SudokuController(
        preferencesStore: fakePrefs,
        billingService: fakeBilling,
      );
      await controller.ready;

      fakeBilling.emit(
        const BillingPurchaseUpdate(
          status: BillingPurchaseStatus.purchased,
          productId: 'premium_unlock',
          purchaseId: 'purchase-1',
          errorMessage: null,
          pendingCompletion: false,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.entitlement, Entitlement.premium);
      expect(controller.state.entitlement, Entitlement.premium);
      expect(fakePrefs.entitlement, Entitlement.premium);
    },
  );

  test('non-premium purchase updates do not unlock entitlement', () async {
    final fakePrefs = FakePreferencesStore(entitlement: Entitlement.free);
    final fakeBilling = FakeBillingService();
    final controller = SudokuController(
      preferencesStore: fakePrefs,
      billingService: fakeBilling,
    );
    await controller.ready;

    fakeBilling.emit(
      const BillingPurchaseUpdate(
        status: BillingPurchaseStatus.purchased,
        productId: 'other_product',
        purchaseId: 'purchase-2',
        errorMessage: null,
        pendingCompletion: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.entitlement, Entitlement.free);
    expect(controller.state.entitlement, Entitlement.free);
    expect(fakePrefs.entitlement, Entitlement.free);
  });

  test(
    'controller buyPremium and restorePurchases delegate to billing',
    () async {
      final fakeBilling = FakeBillingService(
        buyResult: BillingActionResult.started,
        restoreResult: BillingActionResult.unavailable,
      );
      final controller = SudokuController(
        preferencesStore: FakePreferencesStore(),
        billingService: fakeBilling,
      );
      await controller.ready;

      final buyResult = await controller.buyPremium();
      final restoreResult = await controller.restorePurchases();

      expect(buyResult, BillingActionResult.started);
      expect(restoreResult, BillingActionResult.unavailable);
    },
  );
}
