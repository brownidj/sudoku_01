import 'package:flutter_app/app/entitlement_service.dart';
import 'package:flutter_app/domain/types.dart';

class EntitlementSyncService {
  final EntitlementService _entitlementService;

  const EntitlementSyncService(this._entitlementService);

  Future<Entitlement> loadStartupEntitlement({
    Entitlement fallback = Entitlement.free,
  }) async {
    try {
      return await _entitlementService.loadEntitlement();
    } on Exception {
      return fallback;
    }
  }

  Future<Entitlement> refreshEntitlement({
    required Entitlement fallback,
  }) async {
    try {
      return await _entitlementService.loadEntitlement();
    } on Exception {
      return fallback;
    }
  }

  Future<void> persistEntitlement(Entitlement entitlement) {
    return _entitlementService.saveEntitlement(entitlement);
  }
}
