import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/monetization_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class InAppPurchaseApi {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});

  Future<void> restorePurchases({String? applicationUserName});
}

class DefaultInAppPurchaseApi implements InAppPurchaseApi {
  final InAppPurchase _inAppPurchase;

  DefaultInAppPurchaseApi({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return _inAppPurchase.queryProductDetails(identifiers);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) {
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    return _inAppPurchase.restorePurchases(
      applicationUserName: applicationUserName,
    );
  }
}

class InAppPurchaseBillingService implements BillingService {
  final InAppPurchaseApi _inAppPurchaseApi;
  final String _premiumProductId;
  final Map<String, ProductDetails> _productDetailsById =
      <String, ProductDetails>{};

  InAppPurchaseBillingService({
    InAppPurchaseApi? inAppPurchaseApi,
    String? premiumProductId,
  }) : _inAppPurchaseApi = inAppPurchaseApi ?? DefaultInAppPurchaseApi(),
       _premiumProductId =
           premiumProductId ??
           MonetizationConfig.premiumUnlockIdForCurrentPlatform();

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates {
    return _inAppPurchaseApi.purchaseStream
        .expand((updates) => updates)
        .map(_mapPurchaseUpdate);
  }

  @override
  Future<bool> isAvailable() => _inAppPurchaseApi.isAvailable();

  @override
  Future<List<BillingProduct>> loadProducts() async {
    final productId = _premiumProductId.trim();
    if (productId.isEmpty) {
      return const <BillingProduct>[];
    }
    final response = await _inAppPurchaseApi.queryProductDetails({productId});
    _productDetailsById
      ..clear()
      ..addEntries(
        response.productDetails.map((details) => MapEntry(details.id, details)),
      );
    return response.productDetails
        .map(
          (details) => BillingProduct(
            id: details.id,
            title: details.title,
            description: details.description,
            priceLabel: details.price,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<BillingActionResult> buyPremium() async {
    final productId = _premiumProductId.trim();
    if (productId.isEmpty) {
      return BillingActionResult.productNotConfigured;
    }
    if (!await _inAppPurchaseApi.isAvailable()) {
      return BillingActionResult.unavailable;
    }
    if (!_productDetailsById.containsKey(productId)) {
      await loadProducts();
    }
    final productDetails = _productDetailsById[productId];
    if (productDetails == null) {
      return BillingActionResult.productUnavailable;
    }
    try {
      final requestStarted = await _inAppPurchaseApi.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
      return requestStarted
          ? BillingActionResult.started
          : BillingActionResult.failed;
    } on Exception {
      return BillingActionResult.failed;
    }
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    if (!await _inAppPurchaseApi.isAvailable()) {
      return BillingActionResult.unavailable;
    }
    try {
      await _inAppPurchaseApi.restorePurchases();
      return BillingActionResult.started;
    } on Exception {
      return BillingActionResult.failed;
    }
  }

  BillingPurchaseUpdate _mapPurchaseUpdate(PurchaseDetails details) {
    return BillingPurchaseUpdate(
      status: _mapPurchaseStatus(details.status),
      productId: details.productID,
      purchaseId: details.purchaseID,
      errorMessage: details.error?.message,
      pendingCompletion: details.pendingCompletePurchase,
    );
  }

  BillingPurchaseStatus _mapPurchaseStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return BillingPurchaseStatus.pending;
      case PurchaseStatus.purchased:
        return BillingPurchaseStatus.purchased;
      case PurchaseStatus.restored:
        return BillingPurchaseStatus.restored;
      case PurchaseStatus.canceled:
        return BillingPurchaseStatus.canceled;
      case PurchaseStatus.error:
        return BillingPurchaseStatus.error;
    }
  }
}
