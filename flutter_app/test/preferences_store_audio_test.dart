import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesStore audio settings', () {
    test('defaults audio and background music to on with medium volume', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesStore();

      expect(await store.loadAudioEnabled(), isTrue);
      expect(await store.loadBackgroundMusicEnabled(), isTrue);
      expect(await store.loadAudioVolume(), 0.5);
    });

    test('persists and restores audio toggles and volume', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesStore();

      await store.saveAudioEnabled(false);
      await store.saveBackgroundMusicEnabled(false);
      await store.saveAudioVolume(0.8);

      expect(await store.loadAudioEnabled(), isFalse);
      expect(await store.loadBackgroundMusicEnabled(), isFalse);
      expect(await store.loadAudioVolume(), 0.8);
    });
  });
}
