import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/in_app_purchase_billing_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/in_app_purchase_billing_test_support.dart';

void main() {
  const premiumId = 'full_unlock';

  test('buyPremium returns unavailable when store is unavailable', () async {
    final api = FakeInAppPurchaseApi(
      available: false,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );
    final result = await service.buyPremium();
    expect(result, BillingActionResult.unavailable);
  });

  test('buyPremium returns productNotConfigured when id is blank', () async {
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: const <ProductDetails>[],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: '   ',
    );
    final result = await service.buyPremium();
    expect(result, BillingActionResult.productNotConfigured);
  });

  test(
    'buyPremium returns productUnavailable when product query is empty',
    () async {
      final api = FakeInAppPurchaseApi(
        available: true,
        buyShouldSucceed: true,
        restoreShouldThrow: false,
        completeShouldThrow: false,
        productDetailsResponse: ProductDetailsResponse(
          productDetails: const <ProductDetails>[],
          notFoundIDs: const <String>[premiumId],
        ),
      );
      final service = InAppPurchaseBillingService(
        inAppPurchaseApi: api,
        premiumProductId: premiumId,
      );
      final result = await service.buyPremium();
      expect(result, BillingActionResult.productUnavailable);
    },
  );

  test(
    'buyPremium returns started when request is successfully sent',
    () async {
      final api = FakeInAppPurchaseApi(
        available: true,
        buyShouldSucceed: true,
        restoreShouldThrow: false,
        completeShouldThrow: false,
        productDetailsResponse: ProductDetailsResponse(
          productDetails: <ProductDetails>[product(id: premiumId)],
          notFoundIDs: const <String>[],
        ),
      );
      final service = InAppPurchaseBillingService(
        inAppPurchaseApi: api,
        premiumProductId: premiumId,
      );
      final result = await service.buyPremium();
      expect(result, BillingActionResult.started);
    },
  );

  test('purchase stream maps platform updates into billing updates', () async {
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );
    final updates = <BillingPurchaseUpdate>[];
    final sub = service.purchaseUpdates.listen(updates.add);
    api.emitPurchase(
      purchaseDetails(productId: premiumId, status: PurchaseStatus.purchased),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates, hasLength(1));
    expect(updates.first.productId, premiumId);
    expect(updates.first.status, BillingPurchaseStatus.purchased);
    expect(api.completePurchaseCalls, 0);
    await sub.cancel();
  });

  test('purchase stream completes pending purchases', () async {
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );
    final updates = <BillingPurchaseUpdate>[];
    final sub = service.purchaseUpdates.listen(updates.add);
    api.emitPurchase(
      purchaseDetails(
        productId: premiumId,
        status: PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates, hasLength(1));
    expect(api.completePurchaseCalls, 1);
    await sub.cancel();
  });

  test(
    'purchase stream still emits update when completePurchase throws',
    () async {
      final api = FakeInAppPurchaseApi(
        available: true,
        buyShouldSucceed: true,
        restoreShouldThrow: false,
        completeShouldThrow: true,
        productDetailsResponse: ProductDetailsResponse(
          productDetails: <ProductDetails>[product(id: premiumId)],
          notFoundIDs: const <String>[],
        ),
      );
      final service = InAppPurchaseBillingService(
        inAppPurchaseApi: api,
        premiumProductId: premiumId,
      );
      final updates = <BillingPurchaseUpdate>[];
      final sub = service.purchaseUpdates.listen(updates.add);
      api.emitPurchase(
        purchaseDetails(
          productId: premiumId,
          status: PurchaseStatus.purchased,
          pendingCompletePurchase: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(updates, hasLength(1));
      expect(api.completePurchaseCalls, 1);
      await sub.cancel();
    },
  );

  test('restorePurchases returns failed when restore throws', () async {
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: true,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );
    final result = await service.restorePurchases();
    expect(result, BillingActionResult.failed);
  });

  test('redeemCode returns unavailable outside iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );

    final result = await service.redeemCode();

    expect(result, BillingActionResult.unavailable);
    expect(api.presentCodeRedemptionSheetCalls, 0);
  });

  test('redeemCode presents StoreKit redemption sheet on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );

    final result = await service.redeemCode();

    expect(result, BillingActionResult.started);
    expect(api.presentCodeRedemptionSheetCalls, 1);
  });

  test('redeemCode returns failed when StoreKit sheet throws', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final api = FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      redeemShouldThrow: true,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[product(id: premiumId)],
        notFoundIDs: const <String>[],
      ),
    );
    final service = InAppPurchaseBillingService(
      inAppPurchaseApi: api,
      premiumProductId: premiumId,
    );

    final result = await service.redeemCode();

    expect(result, BillingActionResult.failed);
    expect(api.presentCodeRedemptionSheetCalls, 1);
  });
}
