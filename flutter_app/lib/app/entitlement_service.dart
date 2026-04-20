import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/domain/types.dart';

class EntitlementService {
  final PreferencesStore _preferencesStore;

  const EntitlementService(this._preferencesStore);

  Future<Entitlement> loadEntitlement() {
    return _preferencesStore.loadEntitlement();
  }

  Future<void> saveEntitlement(Entitlement entitlement) {
    return _preferencesStore.saveEntitlement(entitlement);
  }
}
