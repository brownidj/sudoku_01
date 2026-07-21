import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class DelayedPreferencesStore extends PreferencesStore {
  final Completer<void> saveCompleter = Completer<void>();
  String? savedSession;

  @override
  Future<String?> loadGameSession() async => savedSession;

  @override
  Future<void> saveGameSession(String value) async {
    await saveCompleter.future;
    savedSession = value;
  }
}

void main() {
  test('flushPendingSave waits for an in-flight session save', () async {
    final prefs = DelayedPreferencesStore();
    final service = GameSessionService(prefs, GridUtils());
    final history = History.initial(GameState(board: Board.empty()));
    const settings = SettingsState(
      notesMode: false,
      difficulty: 'easy',
      canChangeDifficulty: true,
      canChangePuzzleMode: true,
      styleName: 'Modern',
      contentMode: 'numbers',
      animalStyle: 'simple',
      puzzleMode: 'multi',
    );

    service.save(
      history: history,
      selected: null,
      gameOver: false,
      puzzleSolved: false,
      initialGrid: null,
      settings: settings,
      correctionState: CorrectionState.initial(
        difficulty: 'easy',
        history: history,
      ),
      debugScenarioLabel: null,
      conflictHintsLeft: 3,
      puzzleStartedAt: DateTime(2026, 5, 10, 9, 0),
      puzzleFinishedAt: null,
      activeElapsedSeconds: 0,
      activeTimingStartedAt: DateTime(2026, 5, 10, 9, 0),
    );

    var flushed = false;
    service.flushPendingSave().then((_) {
      flushed = true;
    });
    await Future<void>.delayed(Duration.zero);
    expect(flushed, isFalse);

    prefs.saveCompleter.complete();
    await service.flushPendingSave();

    expect(flushed, isTrue);
    expect(prefs.savedSession, isNotNull);
  });

  test('save and restore round trips puzzle timing fields', () async {
    final prefs = DelayedPreferencesStore();
    final service = GameSessionService(prefs, GridUtils());
    final history = History.initial(GameState(board: Board.empty()));
    const settings = SettingsState(
      notesMode: false,
      difficulty: 'easy',
      canChangeDifficulty: true,
      canChangePuzzleMode: true,
      styleName: 'Modern',
      contentMode: 'numbers',
      animalStyle: 'simple',
      puzzleMode: 'multi',
    );
    final startedAt = DateTime(2026, 5, 10, 9, 0);
    final finishedAt = DateTime(2026, 5, 10, 9, 12, 30);

    final save = service.save(
      history: history,
      selected: null,
      gameOver: false,
      puzzleSolved: true,
      initialGrid: null,
      settings: settings,
      correctionState: CorrectionState.initial(
        difficulty: 'easy',
        history: history,
      ),
      debugScenarioLabel: null,
      conflictHintsLeft: 3,
      puzzleStartedAt: startedAt,
      puzzleFinishedAt: finishedAt,
      activeElapsedSeconds: 420,
      activeTimingStartedAt: null,
    );
    prefs.saveCompleter.complete();
    await save;

    final payload = jsonDecode(prefs.savedSession!) as Map<String, dynamic>;
    expect(payload['puzzleStartedAt'], startedAt.toIso8601String());
    expect(payload['puzzleFinishedAt'], finishedAt.toIso8601String());
    expect(payload['activeElapsedSeconds'], 420);
    expect(payload['activeTimingStartedAt'], isNull);

    final restored = await service.restore(settings);
    expect(restored, isNotNull);
    expect(restored!.puzzleStartedAt, startedAt);
    expect(restored.puzzleFinishedAt, finishedAt);
    expect(restored.activeElapsedSeconds, 420);
    expect(restored.activeTimingStartedAt, isNull);
  });
}
