import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class FakePreferencesStore extends PreferencesStore {
  String? savedSession;
  int completedPuzzles;
  Entitlement entitlement;

  FakePreferencesStore({
    this.savedSession,
    this.completedPuzzles = 0,
    this.entitlement = Entitlement.free,
  });

  @override
  Future<AppPreferences> load() async {
    return const AppPreferences(
      animalStyle: null,
      contentMode: null,
      styleName: null,
      difficulty: null,
      puzzleMode: null,
    );
  }

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
  Future<String?> loadGameSession() async => savedSession;

  @override
  Future<void> saveGameSession(String value) async {
    savedSession = value;
  }

  @override
  Future<int> loadCompletedPuzzles() async => completedPuzzles;

  @override
  Future<void> saveCompletedPuzzles(int value) async {
    completedPuzzles = value;
  }

  @override
  Future<Entitlement> loadEntitlement() async => entitlement;

  @override
  Future<void> saveEntitlement(Entitlement value) async {
    entitlement = value;
  }
}

class FakeSettingsController extends SettingsController {
  SettingsState _state;
  int loadCalls = 0;

  FakeSettingsController(this._state) : super(FakePreferencesStore(), () {});

  @override
  SettingsState get state => _state;

  @override
  Future<void> load() async {
    loadCalls += 1;
  }

  @override
  void toggleNotesMode() {
    _state = _state.copyWith(notesMode: !_state.notesMode);
  }

  @override
  bool setDifficulty(String difficulty) {
    _state = _state.copyWith(difficulty: difficulty);
    return true;
  }

  @override
  void setDifficultyLocked(bool locked) {
    _state = _state.copyWith(canChangeDifficulty: !locked);
  }

  @override
  void setPuzzleModeLocked(bool locked) {
    _state = _state.copyWith(canChangePuzzleMode: !locked);
  }

  @override
  void setStyleName(String styleName) {
    _state = _state.copyWith(styleName: styleName);
  }

  @override
  void setContentMode(String mode) {
    _state = _state.copyWith(contentMode: mode);
  }

  @override
  void setAnimalStyle(String style) {
    _state = _state.copyWith(animalStyle: style);
  }

  @override
  void setPuzzleMode(String mode) {
    _state = _state.copyWith(puzzleMode: mode);
  }
}

class FakeGameService extends GameService {
  int initialHistoryCalls = 0;
  int newGameCalls = 0;

  @override
  History initialHistory() {
    initialHistoryCalls += 1;
    return super.initialHistory();
  }

  @override
  MoveResult newGameFromGrid(Grid grid) {
    newGameCalls += 1;
    return super.newGameFromGrid(grid);
  }
}

class SpyPremiumPolicyService extends PremiumPolicyService {
  final List<String> difficultyChecks = <String>[];
  bool defaultDifficultyResult;
  final Map<String, bool> byDifficulty;

  SpyPremiumPolicyService({
    this.defaultDifficultyResult = true,
    Map<String, bool>? byDifficulty,
  }) : byDifficulty = byDifficulty ?? <String, bool>{};

  @override
  bool isDifficultyUnlocked(String difficulty, Entitlement entitlement) {
    final normalized = difficulty.trim().toLowerCase();
    difficultyChecks.add('$normalized:${entitlement.name}');
    return byDifficulty[normalized] ?? defaultDifficultyResult;
  }
}

Coord? firstEditableCoord(UiState state) {
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      final cell = state.board.cells[r][c];
      if (!cell.given) {
        return Coord(r, c);
      }
    }
  }
  return null;
}

int? conflictingPeerDigit(UiState state, Coord coord) {
  for (var c = 0; c < 9; c += 1) {
    if (c == coord.col) {
      continue;
    }
    final value = state.board.cells[coord.row][c].value;
    if (value != null) {
      return value;
    }
  }
  for (var r = 0; r < 9; r += 1) {
    if (r == coord.row) {
      continue;
    }
    final value = state.board.cells[r][coord.col].value;
    if (value != null) {
      return value;
    }
  }
  final boxRow = (coord.row ~/ 3) * 3;
  final boxCol = (coord.col ~/ 3) * 3;
  for (var r = boxRow; r < boxRow + 3; r += 1) {
    for (var c = boxCol; c < boxCol + 3; c += 1) {
      if (r == coord.row && c == coord.col) {
        continue;
      }
      final value = state.board.cells[r][c].value;
      if (value != null) {
        return value;
      }
    }
  }
  return null;
}
