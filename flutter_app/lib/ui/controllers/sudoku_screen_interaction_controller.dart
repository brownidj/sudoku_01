import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/services/debug_toggle_service.dart';

class VersionTapResult {
  final bool completePuzzle;
  final bool toggleDebugTools;

  const VersionTapResult({
    required this.completePuzzle,
    required this.toggleDebugTools,
  });
}

class SudokuScreenInteractionController {
  final SudokuController _sudokuController;
  final CandidatePanelCoordinator _candidatePanelCoordinator;
  final DebugToggleService _debugToggleService;
  final DateTime Function() _now;

  SudokuScreenInteractionController({
    required SudokuController sudokuController,
    required CandidatePanelCoordinator candidatePanelCoordinator,
    required DebugToggleService debugToggleService,
    DateTime Function()? now,
  }) : _sudokuController = sudokuController,
       _candidatePanelCoordinator = candidatePanelCoordinator,
       _debugToggleService = debugToggleService,
       _now = now ?? DateTime.now;

  Future<void> onCellTapped({
    required UiState state,
    required Coord coord,
    required Future<void>? animalLoad,
  }) async {
    _sudokuController.onCellTapped(coord);
    await _candidatePanelCoordinator.onCellTapped(
      state: state,
      coord: coord,
      animalLoad: animalLoad,
      setNotesMode: _sudokuController.setNotesMode,
    );
  }

  void onCandidateDigitSelected(int digit) {
    if (digit == 0) {
      _sudokuController.onClearPressed();
    } else {
      _sudokuController.onDigitPressed(digit);
    }
    _candidatePanelCoordinator.onDigitApplied(
      digit: digit,
      nextState: _sudokuController.state,
    );
  }

  void onCandidateDigitLongPressed(int digit) {
    if (digit == 0) {
      return;
    }
    _sudokuController.onPlaceDigit(digit);
    _candidatePanelCoordinator.onPlacedDigitViaLongPress();
  }

  void onCheckOrSolutionPressed(UiState state) {
    _candidatePanelCoordinator.onCheckOrSolution();
    if (state.gameOver) {
      _sudokuController.onShowSolution();
      return;
    }
    _sudokuController.onCheckSolution();
  }

  VersionTapResult onVersionTapped({required bool appDebugEnabled}) {
    var shouldToggleDebug = false;
    if (appDebugEnabled) {
      shouldToggleDebug = _debugToggleService.registerVersionTap(_now());
    }

    return VersionTapResult(
      completePuzzle: false,
      toggleDebugTools: shouldToggleDebug,
    );
  }

  void onVersionLongPressed() {
    _candidatePanelCoordinator.onCheckOrSolution();
    _sudokuController.onCompletePuzzleWithSolution();
  }
}
