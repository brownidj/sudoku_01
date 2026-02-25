import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class FakePreferencesStore extends PreferencesStore {
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

Coord? _firstEditableCoord(UiState state) {
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

void main() {
  test('SudokuController uses injected services', () {
    final fakeGameService = FakeGameService();
    final fakeSettings = FakeSettingsController(
      const SettingsState(
        notesMode: true,
        difficulty: 'hard',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Classic',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'unique',
      ),
    );

    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: fakeGameService,
      settingsController: fakeSettings,
    );

    expect(fakeGameService.initialHistoryCalls, 1);
    expect(fakeGameService.newGameCalls, 1);
    expect(fakeSettings.loadCalls, 1);

    final state = controller.state;
    expect(state.difficulty, 'hard');
    expect(state.styleName, 'Classic');
    expect(state.contentMode, 'numbers');
    expect(state.animalStyle, 'simple');
  });

  test('Puzzle mode defaults, locking, and new game flow', () {
    final fakeGameService = FakeGameService();
    final fakeSettings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'multi',
      ),
    );

    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
      gameService: fakeGameService,
      settingsController: fakeSettings,
    );

    expect(fakeGameService.newGameCalls, 1);

    controller.onSetDifficulty('medium');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 2);

    controller.onPuzzleModeChanged('multi');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    final editable = _firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);
    expect(fakeSettings.state.canChangePuzzleMode, false);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    controller.onCheckSolution();
    expect(fakeSettings.state.canChangePuzzleMode, true);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 4);

    controller.onSetDifficulty('hard');
    expect(fakeSettings.state.puzzleMode, 'unique');
  });
}
