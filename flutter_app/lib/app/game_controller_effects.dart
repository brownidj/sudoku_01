import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';

class GameControllerEffects {
  final GameSessionService _sessionService;

  const GameControllerEffects(this._sessionService);

  void saveGameSession({
    required SudokuRuntimeState runtime,
    required SettingsState settings,
  }) {
    _sessionService.save(
      history: runtime.history,
      selected: runtime.selected,
      gameOver: runtime.gameOver,
      puzzleSolved: runtime.puzzleSolved,
      initialGrid: runtime.initialGrid,
      settings: settings,
      correctionState: runtime.correctionState,
      debugScenarioLabel: runtime.debugScenarioLabel,
    );
  }

  void render(VoidCallback notifyListeners, String status) {
    notifyListeners();
  }

  Future<void> flushPendingSave() => _sessionService.flushPendingSave();
}
