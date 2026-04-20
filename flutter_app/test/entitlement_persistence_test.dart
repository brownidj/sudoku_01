import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesStore entitlement persistence', () {
    test('defaults to free when no value is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesStore();

      final entitlement = await store.loadEntitlement();

      expect(entitlement, Entitlement.free);
    });

    test('restores saved premium entitlement', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesStore();

      await store.saveEntitlement(Entitlement.premium);
      final entitlement = await store.loadEntitlement();

      expect(entitlement, Entitlement.premium);
    });

    test('falls back to free for unknown persisted values', () async {
      SharedPreferences.setMockInitialValues({
        PreferencesStore.keyEntitlement: 'legacy_unknown_value',
      });
      final store = PreferencesStore();

      final entitlement = await store.loadEntitlement();

      expect(entitlement, Entitlement.free);
    });
  });
}
