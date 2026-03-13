import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class DebugScenario {
  final String label;
  final History history;
  final CorrectionState correctionState;
  final Grid initialGrid;
  final SettingsState settings;
  final Coord? selected;

  const DebugScenario({
    required this.label,
    required this.history,
    required this.correctionState,
    required this.initialGrid,
    required this.settings,
    required this.selected,
  });
}

class DebugScenarios {
  const DebugScenarios._();

  static DebugScenario correctionRecovery({
    required GameService service,
    required SettingsState currentSettings,
    int? tokensLeft,
  }) {
    return _buildCorrectionScenario(
      service: service,
      currentSettings: currentSettings,
      tokensLeft: tokensLeft ?? correctionsForDifficulty('easy'),
      pendingPrompt: true,
    );
  }

  static DebugScenario exhaustedCorrectionRecovery({
    required GameService service,
    required SettingsState currentSettings,
  }) {
    return _buildCorrectionScenario(
      service: service,
      currentSettings: currentSettings,
      tokensLeft: 0,
      pendingPrompt: false,
    );
  }

  static Grid _copyGrid(Grid source) {
    return List<List<Digit?>>.generate(9, (r) {
      return List<Digit?>.generate(9, (c) => source[r][c], growable: false);
    }, growable: false);
  }

  static DebugScenario _buildCorrectionScenario({
    required GameService service,
    required SettingsState currentSettings,
    required int tokensLeft,
    required bool pendingPrompt,
  }) {
    final puzzle = puzzles.getPuzzle('starter');
    final initialHistory = service.newGameFromGrid(puzzle.grid).history;
    final checkpoints = <CorrectionCheckpoint>[
      CorrectionCheckpoint(history: initialHistory, moveId: 0),
    ];

    var history = initialHistory;
    var moveId = 0;
    final setupMoves = <({Coord coord, Digit digit})>[
      (coord: const Coord(4, 4), digit: 5),
      (coord: const Coord(6, 5), digit: 7),
      (coord: const Coord(7, 7), digit: 3),
      (coord: const Coord(2, 0), digit: 1),
    ];

    for (final move in setupMoves) {
      history = service.placeDigit(history, move.coord, move.digit).history;
      moveId += 1;
      checkpoints.add(CorrectionCheckpoint(history: history, moveId: moveId));
    }

    history = service.placeDigit(history, const Coord(0, 8), 4).history;
    moveId += 1;

    return DebugScenario(
      label: pendingPrompt
          ? 'Debug scenario: correction available'
          : 'Debug scenario: corrections exhausted',
      history: history,
      correctionState: CorrectionState(
        tokensLeft: tokensLeft,
        currentMoveId: moveId,
        checkpoints: checkpoints,
        revertedCells: const {},
        pendingPromptCoord: pendingPrompt ? const Coord(6, 8) : null,
      ),
      initialGrid: _copyGrid(puzzle.grid),
      settings: currentSettings.copyWith(
        difficulty: puzzle.difficulty,
        puzzleMode: 'multi',
        canChangeDifficulty: false,
        canChangePuzzleMode: false,
      ),
      selected: pendingPrompt ? const Coord(6, 8) : const Coord(0, 8),
    );
  }
}
