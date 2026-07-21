import 'dart:async';

import 'package:flutter_app/app/in_app_purchase_billing_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class FakeInAppPurchaseApi implements InAppPurchaseApi {
  bool available;
  bool buyShouldSucceed;
  bool restoreShouldThrow;
  bool redeemShouldThrow;
  bool completeShouldThrow;
  int completePurchaseCalls = 0;
  int presentCodeRedemptionSheetCalls = 0;
  ProductDetailsResponse productDetailsResponse;
  final StreamController<List<PurchaseDetails>> _purchaseStreamController =
      StreamController<List<PurchaseDetails>>.broadcast();

  FakeInAppPurchaseApi({
    required this.available,
    required this.buyShouldSucceed,
    required this.restoreShouldThrow,
    this.redeemShouldThrow = false,
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
  Future<void> presentCodeRedemptionSheet() async {
    presentCodeRedemptionSheetCalls += 1;
    if (redeemShouldThrow) {
      throw Exception('redeem failed');
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

ProductDetails product({required String id}) {
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

PurchaseDetails purchaseDetails({
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
