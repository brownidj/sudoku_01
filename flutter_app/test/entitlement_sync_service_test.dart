import 'package:flutter_app/app/entitlement_service.dart';
import 'package:flutter_app/app/entitlement_sync_service.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEntitlementService extends EntitlementService {
  Entitlement entitlement;
  bool throwOnLoad;

  _FakeEntitlementService({required this.entitlement, this.throwOnLoad = false})
    : super(PreferencesStore());

  @override
  Future<Entitlement> loadEntitlement() async {
    if (throwOnLoad) {
      throw Exception('load failed');
    }
    return entitlement;
  }

  @override
  Future<void> saveEntitlement(Entitlement entitlement) async {
    this.entitlement = entitlement;
  }
}

void main() {
  test('loadStartupEntitlement returns loaded entitlement', () async {
    final service = EntitlementSyncService(
      _FakeEntitlementService(entitlement: Entitlement.premium),
    );

    final loaded = await service.loadStartupEntitlement();

    expect(loaded, Entitlement.premium);
  });

  test('refreshEntitlement falls back when load fails', () async {
    final service = EntitlementSyncService(
      _FakeEntitlementService(
        entitlement: Entitlement.premium,
        throwOnLoad: true,
      ),
    );

    final refreshed = await service.refreshEntitlement(
      fallback: Entitlement.free,
    );

    expect(refreshed, Entitlement.free);
  });
}
