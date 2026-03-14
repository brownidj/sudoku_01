import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/game_session_codec.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class RestoredGameSession {
  final History history;
  final Coord? selected;
  final bool gameOver;
  final Grid initialGrid;
  final SettingsState settings;
  final CorrectionState correctionState;
  final String? debugScenarioLabel;

  const RestoredGameSession({
    required this.history,
    required this.selected,
    required this.gameOver,
    required this.initialGrid,
    required this.settings,
    required this.correctionState,
    required this.debugScenarioLabel,
  });
}

class GameSessionService {
  static const int sessionVersion = 2;

  final PreferencesStore _prefs;
  final GridUtils _gridUtils;
  final GameSessionCodec _codec;
  Future<void> _pendingSave = Future<void>.value();
  String? _queuedPayload;
  bool _saveRunning = false;

  GameSessionService(
    this._prefs,
    this._gridUtils, {
    GameSessionCodec codec = const GameSessionCodec(),
  }) : _codec = codec;

  Future<RestoredGameSession?> restore(SettingsState fallback) async {
    final raw = await _prefs.loadGameSession();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (decoded['version'] != sessionVersion) {
        return null;
      }

      final boardRaw = decoded['board'];
      if (boardRaw is! List) {
        return null;
      }

      final restoredBoard = _codec.boardFromJson(boardRaw);
      if (restoredBoard == null) {
        return null;
      }

      final initialGrid =
          _codec.gridFromJson(decoded['initialGrid']) ??
          _gridUtils.gridFromBoard(restoredBoard);
      final settings = _codec.settingsFromJson(decoded['settings'], fallback);
      final history = History.initial(GameState(board: restoredBoard));
      final correctionState = _codec.correctionStateFromJson(
        decoded['corrections'],
        settings.difficulty,
        history,
      );

      return RestoredGameSession(
        history: history,
        selected: _codec.coordFromJson(decoded['selected']),
        gameOver: decoded['gameOver'] == true,
        initialGrid: initialGrid,
        settings: settings,
        correctionState: correctionState,
        debugScenarioLabel: decoded['debugScenarioLabel'] as String?,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> save({
    required History history,
    required Coord? selected,
    required bool gameOver,
    required Grid? initialGrid,
    required SettingsState settings,
    required CorrectionState correctionState,
    required String? debugScenarioLabel,
  }) {
    final payload = <String, dynamic>{
      'version': sessionVersion,
      'board': _codec.boardToJson(history.present.board),
      'initialGrid': _codec.gridToJson(initialGrid),
      'selected': _codec.coordToJson(selected),
      'gameOver': gameOver,
      'debugScenarioLabel': debugScenarioLabel,
      'settings': <String, dynamic>{
        'notesMode': settings.notesMode,
        'difficulty': settings.difficulty,
        'canChangeDifficulty': settings.canChangeDifficulty,
        'canChangePuzzleMode': settings.canChangePuzzleMode,
        'styleName': settings.styleName,
        'contentMode': settings.contentMode,
        'animalStyle': settings.animalStyle,
        'puzzleMode': settings.puzzleMode,
      },
      'corrections': _codec.correctionStateToJson(correctionState),
    };
    _queuedPayload = jsonEncode(payload);
    if (_saveRunning) {
      return _pendingSave;
    }
    _saveRunning = true;
    _pendingSave = _drainSaveQueue();
    return _pendingSave;
  }

  Future<void> flushPendingSave() {
    return _pendingSave;
  }

  Future<void> _drainSaveQueue() async {
    while (_queuedPayload != null) {
      final payload = _queuedPayload!;
      _queuedPayload = null;
      try {
        await _prefs.saveGameSession(payload);
      } on Exception {
        // Best-effort persistence; callers continue from in-memory state.
      } on Error {
        // Best-effort persistence; callers continue from in-memory state.
      }
    }
    _saveRunning = false;
  }
}
