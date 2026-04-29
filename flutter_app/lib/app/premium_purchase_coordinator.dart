import 'dart:async';

import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/entitlement_sync_service.dart';
import 'package:flutter_app/app/monetization_config.dart';
import 'package:flutter_app/domain/types.dart';

class PremiumPurchaseCoordinator {
  final BillingService _billingService;
  final EntitlementSyncService _entitlementSyncService;
  final Set<String> _premiumProductIds;
  StreamSubscription<BillingPurchaseUpdate>? _purchaseSubscription;
  bool _handlingPremiumUnlock = false;

  PremiumPurchaseCoordinator({
    required BillingService billingService,
    required EntitlementSyncService entitlementSyncService,
    Set<String>? premiumProductIds,
  }) : _billingService = billingService,
       _entitlementSyncService = entitlementSyncService,
       _premiumProductIds = premiumProductIds ?? MonetizationConfig.productIds;

  void start({required Future<void> Function() onPremiumEntitlementSynced}) {
    _purchaseSubscription ??= _billingService.purchaseUpdates.listen((update) {
      unawaited(
        _handlePurchaseUpdate(
          update,
          onPremiumEntitlementSynced: onPremiumEntitlementSynced,
        ),
      );
    });
  }

  Future<BillingActionResult> buyPremium() {
    return _billingService.buyPremium();
  }

  Future<BillingActionResult> restorePurchases() {
    return _billingService.restorePurchases();
  }

  String? get lastActionDiagnostics => _billingService.lastActionDiagnostics;

  void dispose() {
    final subscription = _purchaseSubscription;
    _purchaseSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  Future<void> _handlePurchaseUpdate(
    BillingPurchaseUpdate update, {
    required Future<void> Function() onPremiumEntitlementSynced,
  }) async {
    if (!_isPremiumUnlockSuccess(update) || _handlingPremiumUnlock) {
      return;
    }
    _handlingPremiumUnlock = true;
    try {
      await _entitlementSyncService.persistEntitlement(Entitlement.premium);
      await onPremiumEntitlementSynced();
    } finally {
      _handlingPremiumUnlock = false;
    }
  }

  bool _isPremiumUnlockSuccess(BillingPurchaseUpdate update) {
    if (!_premiumProductIds.contains(update.productId)) {
      return false;
    }
    return update.status == BillingPurchaseStatus.purchased ||
        update.status == BillingPurchaseStatus.restored;
  }
}
