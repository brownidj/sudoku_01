import 'package:flutter_app/app/game_configuration_service.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('setDifficulty updates puzzle mode and starts a new game', () {
    final service = GameConfigurationService();
    final settings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'hard',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'unique',
      ),
    );
    var startCalls = 0;
    String? status;

    service.setDifficulty(
      settings: settings,
      entitlement: Entitlement.premium,
      difficulty: 'easy',
      startGame: () => startCalls += 1,
      render: (message) => status = message,
    );

    expect(settings.state.difficulty, 'easy');
    expect(settings.state.puzzleMode, 'unique');
    expect(startCalls, 1);
    expect(status, isNull);
  });

  test('setDifficulty blocks premium-gated difficulty for free entitlement', () {
    final service = GameConfigurationService();
    final settings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'unique',
      ),
    );
    var startCalls = 0;
    String? status;

    service.setDifficulty(
      settings: settings,
      entitlement: Entitlement.free,
      difficulty: 'hard',
      startGame: () => startCalls += 1,
      render: (message) => status = message,
    );

    expect(settings.state.difficulty, 'easy');
    expect(startCalls, 0);
    expect(status, 'This difficulty is available in Premium.');
  });

  test('setPuzzleMode renders guidance when mode is locked', () {
    final service = GameConfigurationService();
    final settings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: false,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'multi',
      ),
    );
    var startCalls = 0;
    String? status;

    service.setPuzzleMode(
      settings: settings,
      mode: 'unique',
      startGame: () => startCalls += 1,
      render: (message) => status = message,
    );

    expect(settings.state.puzzleMode, 'multi');
    expect(startCalls, 0);
    expect(status, 'Finish or check the game before changing puzzle mode');
  });
}
