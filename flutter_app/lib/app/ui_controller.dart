import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/game_controller.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/domain/types.dart';

class UiController {
  final GameController _gameController;
  final SettingsController _settings;
  final BoardEditCoordinator _boardEditCoordinator;

  UiController({
    required GameController gameController,
    required SettingsController settingsController,
    required BoardEditCoordinator boardEditCoordinator,
  }) : _gameController = gameController,
       _settings = settingsController,
       _boardEditCoordinator = boardEditCoordinator;

  void onCellTapped(Coord coord, VoidCallback notifyListeners) {
    _gameController.selectCell(coord, notifyListeners);
  }

  void onDigitPressed(Digit digit, VoidCallback notifyListeners) {
    _gameController.applyBoardEditOutcome(
      _boardEditCoordinator.onDigitPressed(
        gameOver: _gameController.gameOver,
        selected: _gameController.selected,
        notesMode: _settings.state.notesMode,
        history: _gameController.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
      notifyListeners,
    );
  }

  void onPlaceDigit(Digit digit, VoidCallback notifyListeners) {
    _gameController.applyBoardEditOutcome(
      _boardEditCoordinator.onPlaceDigit(
        gameOver: _gameController.gameOver,
        selected: _gameController.selected,
        history: _gameController.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
      notifyListeners,
    );
  }

  void onClearPressed(VoidCallback notifyListeners) {
    _gameController.applyBoardEditOutcome(
      _boardEditCoordinator.onClearPressed(
        gameOver: _gameController.gameOver,
        selected: _gameController.selected,
        notesMode: _settings.state.notesMode,
        history: _gameController.history,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
      notifyListeners,
    );
  }

  void onToggleNotesMode(VoidCallback notifyListeners) {
    if (_gameController.gameOver) {
      return;
    }
    _settings.toggleNotesMode();
    notifyListeners();
  }

  void setNotesMode(bool enabled, VoidCallback notifyListeners) {
    if (_gameController.gameOver) {
      return;
    }
    _settings.setNotesMode(enabled);
    notifyListeners();
  }

  void onStyleChanged(String styleName, VoidCallback notifyListeners) {
    _settings.setStyleName(styleName);
    notifyListeners();
  }

  void onContentModeChanged(String mode, VoidCallback notifyListeners) {
    const allowedModes = {'animals', 'instruments', 'numbers'};
    _settings.setContentMode(allowedModes.contains(mode) ? mode : 'numbers');
    notifyListeners();
  }

  void onAnimalStyleChanged(String style, VoidCallback notifyListeners) {
    _settings.setAnimalStyle(style == 'cute' ? 'cute' : 'simple');
    notifyListeners();
  }
}
