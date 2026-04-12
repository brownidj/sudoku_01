import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class GameSessionCodec {
  const GameSessionCodec();

  SettingsState settingsFromJson(Object? raw, SettingsState fallback) {
    if (raw is! Map<String, dynamic>) {
      return fallback;
    }

    final difficulty = _difficultyOrDefault(raw['difficulty'], fallback);
    var puzzleMode = _puzzleModeOrDefault(raw['puzzleMode']);
    if (difficulty == 'hard') {
      puzzleMode = 'unique';
    }

    return fallback.copyWith(
      notesMode: raw['notesMode'] == true,
      difficulty: difficulty,
      canChangeDifficulty: raw['canChangeDifficulty'] != false,
      canChangePuzzleMode: raw['canChangePuzzleMode'] != false,
      styleName: _styleOrDefault(raw['styleName'], fallback),
      contentMode: _contentModeOrDefault(raw['contentMode'], fallback),
      animalStyle: _animalStyleOrDefault(raw['animalStyle'], fallback),
      puzzleMode: puzzleMode,
    );
  }

  List<List<Map<String, dynamic>>> boardToJson(Board board) {
    return List<List<Map<String, dynamic>>>.generate(9, (r) {
      return List<Map<String, dynamic>>.generate(9, (c) {
        final cell = board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        return <String, dynamic>{'v': cell.value, 'g': cell.given, 'n': notes};
      }, growable: false);
    }, growable: false);
  }

  Board? boardFromJson(List<dynamic> raw) {
    if (raw.length != 9) {
      return null;
    }
    final rows = <List<Cell>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }
      final row = <Cell>[];
      for (var c = 0; c < 9; c += 1) {
        final cellRaw = rowRaw[c];
        if (cellRaw is! Map<String, dynamic>) {
          return null;
        }
        final valueRaw = cellRaw['v'];
        final notesRaw = cellRaw['n'];
        final notes = <int>{};
        if (notesRaw is List) {
          for (final note in notesRaw) {
            if (note is int && note >= 1 && note <= 9) {
              notes.add(note);
            }
          }
        }
        row.add(
          Cell(
            value: valueRaw is int ? valueRaw : null,
            given: cellRaw['g'] == true,
            notes: notes,
          ),
        );
      }
      rows.add(row);
    }
    return Board(cells: rows);
  }

  List<List<int?>>? gridToJson(Grid? grid) {
    if (grid == null) {
      return null;
    }
    return List<List<int?>>.generate(9, (r) {
      return List<int?>.generate(9, (c) => grid[r][c], growable: false);
    }, growable: false);
  }

  Grid? gridFromJson(Object? raw) {
    if (raw is! List || raw.length != 9) {
      return null;
    }
    final out = <List<int?>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }
      final row = <int?>[];
      for (var c = 0; c < 9; c += 1) {
        final value = rowRaw[c];
        row.add(value is int ? value : null);
      }
      out.add(row);
    }
    return out;
  }

  Map<String, dynamic> correctionStateToJson(CorrectionState state) {
    return <String, dynamic>{
      'tokensLeft': state.tokensLeft,
      'currentMoveId': state.currentMoveId,
      'pendingPromptCoord': coordToJson(state.pendingPromptCoord),
      'revertedCells': coordsToJson(state.revertedCells),
      'checkpoints': state.checkpoints
          .map((checkpoint) {
            return <String, dynamic>{
              'moveId': checkpoint.moveId,
              'board': boardToJson(checkpoint.board),
            };
          })
          .toList(growable: false),
    };
  }

  CorrectionState correctionStateFromJson(
    Object? raw,
    String difficulty,
    History fallbackHistory,
  ) {
    if (raw is! Map<String, dynamic>) {
      return CorrectionState.initial(
        difficulty: difficulty,
        history: fallbackHistory,
      );
    }

    final checkpointsRaw = raw['checkpoints'];
    final checkpoints = <CorrectionCheckpoint>[];
    if (checkpointsRaw is List) {
      for (final checkpointRaw in checkpointsRaw) {
        if (checkpointRaw is! Map<String, dynamic>) {
          continue;
        }
        final moveId = checkpointRaw['moveId'];
        final boardRaw = checkpointRaw['board'];
        if (moveId is! int || boardRaw is! List) {
          continue;
        }
        final board = boardFromJson(boardRaw);
        if (board == null) {
          continue;
        }
        checkpoints.add(
          CorrectionCheckpoint(
            history: History.initial(GameState(board: board)),
            moveId: moveId,
          ),
        );
      }
    }

    final fallback = CorrectionState.initial(
      difficulty: difficulty,
      history: fallbackHistory,
    );
    final maxTokens = correctionsForDifficulty(difficulty);
    final rawTokensLeft = raw['tokensLeft'] is int
        ? raw['tokensLeft'] as int
        : fallback.tokensLeft;
    return CorrectionState(
      tokensLeft: _clampCorrectionTokens(rawTokensLeft, maxTokens),
      currentMoveId: raw['currentMoveId'] is int
          ? raw['currentMoveId'] as int
          : fallback.currentMoveId,
      checkpoints: checkpoints.isEmpty ? fallback.checkpoints : checkpoints,
      revertedCells: coordsFromJson(raw['revertedCells']),
      pendingPromptCoord: coordFromJson(raw['pendingPromptCoord']),
    );
  }

  Map<String, int>? coordToJson(Coord? coord) {
    if (coord == null) {
      return null;
    }
    return <String, int>{'row': coord.row, 'col': coord.col};
  }

  Coord? coordFromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final row = raw['row'];
    final col = raw['col'];
    if (row is! int || col is! int) {
      return null;
    }
    if (row < 0 || row > 8 || col < 0 || col > 8) {
      return null;
    }
    return Coord(row, col);
  }

  List<Map<String, int>> coordsToJson(Set<Coord> coords) {
    return coords
        .map((coord) => <String, int>{'row': coord.row, 'col': coord.col})
        .toList(growable: false);
  }

  Set<Coord> coordsFromJson(Object? raw) {
    if (raw is! List) {
      return {};
    }
    final coords = <Coord>{};
    for (final item in raw) {
      final coord = coordFromJson(item);
      if (coord != null) {
        coords.add(coord);
      }
    }
    return coords;
  }

  String _difficultyOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'easy' || value == 'medium' || value == 'hard') {
      return value;
    }
    return fallback.difficulty;
  }

  String _puzzleModeOrDefault(Object? raw) {
    final value = raw is String ? raw : '';
    if (value == 'unique' || value == 'multi') {
      return value;
    }
    return 'unique';
  }

  String _styleOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'Modern' || value == 'Classic' || value == 'High Contrast') {
      return value;
    }
    return fallback.styleName;
  }

  String _contentModeOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'animals' || value == 'numbers') {
      return value;
    }
    return fallback.contentMode;
  }

  String _animalStyleOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'cute' || value == 'simple') {
      return value;
    }
    return fallback.animalStyle;
  }

  int _clampCorrectionTokens(int value, int maxTokens) {
    if (value < 0) {
      return 0;
    }
    if (value > maxTokens) {
      return maxTokens;
    }
    return value;
  }
}
