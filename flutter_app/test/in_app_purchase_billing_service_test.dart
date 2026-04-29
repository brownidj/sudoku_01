import 'dart:async';

import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/in_app_purchase_billing_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInAppPurchaseApi implements InAppPurchaseApi {
  bool available;
  bool buyShouldSucceed;
  bool restoreShouldThrow;
  bool completeShouldThrow;
  int completePurchaseCalls = 0;
  ProductDetailsResponse productDetailsResponse;
  final StreamController<List<PurchaseDetails>> _purchaseStreamController =
      StreamController<List<PurchaseDetails>>.broadcast();

  _FakeInAppPurchaseApi({
    required this.available,
    required this.buyShouldSucceed,
    required this.restoreShouldThrow,
    required this.completeShouldThrow,
    required this.productDetailsResponse,
  });

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseStreamController.stream;

  void emitPurchase(PurchaseDetails purchaseDetails) {
    _purchaseStreamController.add(<PurchaseDetails>[purchaseDetails]);
  }

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return productDetailsResponse;
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    return buyShouldSucceed;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    if (restoreShouldThrow) {
      throw Exception('restore failed');
    }
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    completePurchaseCalls += 1;
    if (completeShouldThrow) {
      throw Exception('complete failed');
    }
  }
}

ProductDetails _product({required String id}) {
  return ProductDetails(
    id: id,
    title: 'Premium Unlock',
    description: 'Unlock premium features',
    price: '\$9.99',
    rawPrice: 9.99,
    currencyCode: 'USD',
    currencySymbol: '\$',
  );
}

PurchaseDetails _purchaseDetails({
  required String productId,
  required PurchaseStatus status,
  bool pendingCompletePurchase = false,
}) {
  final details = PurchaseDetails(
    purchaseID: 'purchase-123',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '1700000000000',
    status: status,
  );
  details.pendingCompletePurchase = pendingCompletePurchase;
  return details;
}

void main() {
  const premiumId = 'premium_unlock';

  test('buyPremium returns unavailable when store is unavailable', () async {
    final api = _FakeInAppPurchaseApi(
      available: false,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[_product(id: premiumId)],
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
    final api = _FakeInAppPurchaseApi(
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
      final api = _FakeInAppPurchaseApi(
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
      final api = _FakeInAppPurchaseApi(
        available: true,
        buyShouldSucceed: true,
        restoreShouldThrow: false,
        completeShouldThrow: false,
        productDetailsResponse: ProductDetailsResponse(
          productDetails: <ProductDetails>[_product(id: premiumId)],
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
    final api = _FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[_product(id: premiumId)],
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
      _purchaseDetails(productId: premiumId, status: PurchaseStatus.purchased),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates, hasLength(1));
    expect(updates.first.productId, premiumId);
    expect(updates.first.status, BillingPurchaseStatus.purchased);
    expect(api.completePurchaseCalls, 0);
    await sub.cancel();
  });

  test('purchase stream completes pending purchases', () async {
    final api = _FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: false,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[_product(id: premiumId)],
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
      _purchaseDetails(
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
      final api = _FakeInAppPurchaseApi(
        available: true,
        buyShouldSucceed: true,
        restoreShouldThrow: false,
        completeShouldThrow: true,
        productDetailsResponse: ProductDetailsResponse(
          productDetails: <ProductDetails>[_product(id: premiumId)],
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
        _purchaseDetails(
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
    final api = _FakeInAppPurchaseApi(
      available: true,
      buyShouldSucceed: true,
      restoreShouldThrow: true,
      completeShouldThrow: false,
      productDetailsResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[_product(id: premiumId)],
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
}
