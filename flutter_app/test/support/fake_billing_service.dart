part of 'sudoku_controller_test_support.dart';

class FakeBillingService implements BillingService {
  final StreamController<BillingPurchaseUpdate> _updatesController =
      StreamController<BillingPurchaseUpdate>.broadcast();
  bool available;
  BillingActionResult buyResult;
  BillingActionResult restoreResult;
  BillingActionResult redeemCodeResult;
  List<BillingProduct> products;
  String? diagnostics;

  FakeBillingService({
    this.available = true,
    this.buyResult = BillingActionResult.started,
    this.restoreResult = BillingActionResult.started,
    this.redeemCodeResult = BillingActionResult.started,
    this.products = const <BillingProduct>[],
  });

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates =>
      _updatesController.stream;

  @override
  String? get lastActionDiagnostics => diagnostics;

  void emit(BillingPurchaseUpdate update) => _updatesController.add(update);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<BillingProduct>> loadProducts() async => products;

  @override
  Future<BillingActionResult> buyPremium() async => buyResult;

  @override
  Future<BillingActionResult> restorePurchases() async => restoreResult;

  @override
  Future<BillingActionResult> redeemCode() async => redeemCodeResult;
}
