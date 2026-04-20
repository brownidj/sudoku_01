import 'package:flutter_app/app/game_session_codec.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fallback = SettingsState(
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: 'multi',
  );

  test('settingsFromJson restores very_hard and forces unique puzzle mode', () {
    const codec = GameSessionCodec();
    final restored = codec.settingsFromJson({
      'difficulty': 'very_hard',
      'puzzleMode': 'multi',
    }, fallback);

    expect(restored.difficulty, 'very_hard');
    expect(restored.puzzleMode, 'unique');
  });

  test('settingsFromJson keeps fallback for unknown difficulty', () {
    const codec = GameSessionCodec();
    final restored = codec.settingsFromJson({
      'difficulty': 'impossible_plus',
    }, fallback);

    expect(restored.difficulty, fallback.difficulty);
  });
}
