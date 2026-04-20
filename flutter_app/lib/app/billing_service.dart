enum BillingPurchaseStatus { pending, purchased, restored, canceled, error }

enum BillingActionResult {
  started,
  unavailable,
  productNotConfigured,
  productUnavailable,
  failed,
}

class BillingProduct {
  final String id;
  final String title;
  final String description;
  final String priceLabel;

  const BillingProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
  });
}

class BillingPurchaseUpdate {
  final BillingPurchaseStatus status;
  final String productId;
  final String? purchaseId;
  final String? errorMessage;
  final bool pendingCompletion;

  const BillingPurchaseUpdate({
    required this.status,
    required this.productId,
    required this.purchaseId,
    required this.errorMessage,
    required this.pendingCompletion,
  });
}

abstract class BillingService {
  Stream<BillingPurchaseUpdate> get purchaseUpdates;

  Future<bool> isAvailable();

  Future<List<BillingProduct>> loadProducts();

  Future<BillingActionResult> buyPremium();

  Future<BillingActionResult> restorePurchases();
}

class NoopBillingService implements BillingService {
  const NoopBillingService();

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates =>
      const Stream<BillingPurchaseUpdate>.empty();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<List<BillingProduct>> loadProducts() async => const <BillingProduct>[];

  @override
  Future<BillingActionResult> buyPremium() async {
    return BillingActionResult.unavailable;
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    return BillingActionResult.unavailable;
  }
}
