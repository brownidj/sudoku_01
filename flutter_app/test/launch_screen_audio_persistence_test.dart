import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/launch_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePreferencesStore extends PreferencesStore {
  final AppPreferences loadedPreferences;
  _FakePreferencesStore(this.loadedPreferences);

  @override
  Future<AppPreferences> load() async => loadedPreferences;

  @override
  Future<void> saveAnimalStyle(String value) async {}
  @override
  Future<void> saveContentMode(String value) async {}
  @override
  Future<void> saveStyleName(String value) async {}
  @override
  Future<void> saveDifficulty(String value) async {}
  @override
  Future<void> savePuzzleMode(String value) async {}
  @override
  Future<String?> loadGameSession() async => null;
  @override
  Future<void> saveGameSession(String value) async {}
  @override
  Future<int> loadCompletedPuzzles() async => 0;
  @override
  Future<void> saveCompletedPuzzles(int value) async {}
  @override
  Future<Entitlement> loadEntitlement() async => Entitlement.free;
  @override
  Future<void> saveEntitlement(Entitlement value) async {}
}

void main() {
  testWidgets('Launch honors persisted audio off and hides music controls', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    SharedPreferences.setMockInitialValues(<String, Object>{
      PreferencesStore.keyAudioEnabled: false,
      PreferencesStore.keyBackgroundMusicEnabled: false,
    });
    final controller = SudokuController(
      preferencesStore: _FakePreferencesStore(
        const AppPreferences(
          animalStyle: null,
          contentMode: 'butterflies',
          styleName: null,
          difficulty: null,
          puzzleMode: null,
        ),
      ),
    );
    await controller.ready;
    await tester.pumpWidget(
      MaterialApp(home: LaunchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('appbar-music-note-text')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('appbar-music-prev-button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('appbar-music-next-button')),
      findsNothing,
    );
  });
}
