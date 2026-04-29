import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/monetization_config.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class InAppPurchaseApi {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});

  Future<void> restorePurchases({String? applicationUserName});

  Future<void> completePurchase(PurchaseDetails purchaseDetails);
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

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) {
    return _inAppPurchase.completePurchase(purchaseDetails);
  }
}

class InAppPurchaseBillingService implements BillingService {
  final InAppPurchaseApi _inAppPurchaseApi;
  final String _premiumProductId;
  final Map<String, ProductDetails> _productDetailsById =
      <String, ProductDetails>{};
  String? _lastActionDiagnostics;

  InAppPurchaseBillingService({
    InAppPurchaseApi? inAppPurchaseApi,
    String? premiumProductId,
  }) : _inAppPurchaseApi = inAppPurchaseApi ?? DefaultInAppPurchaseApi(),
       _premiumProductId =
           premiumProductId ??
           MonetizationConfig.premiumUnlockIdForCurrentPlatform();

  @override
  String? get lastActionDiagnostics => _lastActionDiagnostics;

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates {
    return _inAppPurchaseApi.purchaseStream
        .expand((updates) => updates)
        .asyncMap((details) async {
          await _completePurchaseIfNeeded(details);
          return _mapPurchaseUpdate(details);
        });
  }

  @override
  Future<bool> isAvailable() => _inAppPurchaseApi.isAvailable();

  @override
  Future<List<BillingProduct>> loadProducts() async {
    final productId = _premiumProductId.trim();
    if (productId.isEmpty) {
      _lastActionDiagnostics = 'platform product id is empty';
      AppDebug.log(
        '[IAP] loadProducts skipped: empty product id for platform config',
      );
      return const <BillingProduct>[];
    }
    AppDebug.log('[IAP] loadProducts querying ids: [$productId]');
    final response = await _inAppPurchaseApi.queryProductDetails({productId});
    final available = await _inAppPurchaseApi.isAvailable();
    _lastActionDiagnostics =
        'isAvailable=$available '
        'queryIds=[$productId] '
        'products=${response.productDetails.length} '
        'notFound=${response.notFoundIDs}';
    AppDebug.log(
      '[IAP] loadProducts result: products=${response.productDetails.length}, '
      'notFound=${response.notFoundIDs}',
    );
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
      _lastActionDiagnostics = 'buyPremium blocked: product id is empty';
      return BillingActionResult.productNotConfigured;
    }
    final available = await _inAppPurchaseApi.isAvailable();
    if (!available) {
      _lastActionDiagnostics = 'buyPremium blocked: isAvailable=false';
      return BillingActionResult.unavailable;
    }
    if (!_productDetailsById.containsKey(productId)) {
      await loadProducts();
    }
    final productDetails = _productDetailsById[productId];
    if (productDetails == null) {
      _lastActionDiagnostics =
          '${_lastActionDiagnostics ?? ''} buyPremium blocked: '
          'product unavailable for id=$productId';
      return BillingActionResult.productUnavailable;
    }
    try {
      final requestStarted = await _inAppPurchaseApi.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
      _lastActionDiagnostics =
          'buyPremium requestStarted=$requestStarted id=$productId';
      return requestStarted
          ? BillingActionResult.started
          : BillingActionResult.failed;
    } on Exception {
      _lastActionDiagnostics = 'buyPremium exception for id=$productId';
      return BillingActionResult.failed;
    }
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    final available = await _inAppPurchaseApi.isAvailable();
    if (!available) {
      _lastActionDiagnostics = 'restorePurchases blocked: isAvailable=false';
      return BillingActionResult.unavailable;
    }
    try {
      await _inAppPurchaseApi.restorePurchases();
      _lastActionDiagnostics = 'restorePurchases request started';
      return BillingActionResult.started;
    } on Exception {
      _lastActionDiagnostics = 'restorePurchases exception';
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

  Future<void> _completePurchaseIfNeeded(PurchaseDetails details) async {
    if (!details.pendingCompletePurchase) {
      return;
    }
    try {
      await _inAppPurchaseApi.completePurchase(details);
    } on Exception {
      // Keep streaming purchase updates even if finalization fails.
    }
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
