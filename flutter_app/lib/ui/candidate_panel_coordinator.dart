import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_selection_controller.dart';

class CandidatePanelCoordinator {
  final CandidateSelectionController controller;

  CandidatePanelCoordinator(this.controller);

  bool get visible => controller.visible;
  List<int> get candidateDigits => controller.candidateDigits;
  Coord? get candidateCoord => controller.candidateCoord;

  Future<void> onCellTapped({
    required UiState state,
    required Coord coord,
    required Future<void>? animalLoad,
    required void Function(bool enabled) setNotesMode,
  }) async {
    if (state.gameOver) {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    if (cell.given) {
      return;
    }
    if (cell.notes.isNotEmpty && !state.notesMode) {
      setNotesMode(true);
    }
    if (state.contentMode != 'numbers' && animalLoad != null) {
      await animalLoad;
    }
    final candidates = cell.value == null
        ? _remainingDigitsForBlock(state, coord)
        : <int>[];
    controller.show(coord, [...candidates, 0]);
  }

  void onDigitApplied({required int digit, required UiState nextState}) {
    final candidateCoord = controller.candidateCoord;
    final selectedCellConflicted =
        candidateCoord != null &&
        nextState
            .board
            .cells[candidateCoord.row][candidateCoord.col]
            .conflicted;
    if ((digit != 0 && selectedCellConflicted) ||
        (nextState.notesMode && digit != 0)) {
      controller.refresh();
      return;
    }
    if (digit == 0 || !nextState.notesMode) {
      controller.hide();
      return;
    }
    controller.refresh();
  }

  void onPlacedDigitViaLongPress() {
    controller.hide();
  }

  void onCheckOrSolution() {
    controller.hide();
  }

  void onCorrectionConfirmed() {
    controller.hide();
  }

  Set<int> selectedNotes(UiState state) {
    final coord = controller.candidateCoord;
    if (coord == null) {
      return {};
    }
    return state.board.cells[coord.row][coord.col].notes.toSet();
  }

  List<int> _remainingDigitsForBlock(UiState state, Coord coord) {
    final used = <int>{};
    final blockRowStart = (coord.row ~/ 3) * 3;
    final blockColStart = (coord.col ~/ 3) * 3;
    for (var row = blockRowStart; row < blockRowStart + 3; row += 1) {
      for (var col = blockColStart; col < blockColStart + 3; col += 1) {
        final value = state.board.cells[row][col].value;
        if (value != null) {
          used.add(value);
        }
      }
    }

    return [
      for (var digit = 1; digit <= 9; digit += 1)
        if (!used.contains(digit)) digit,
    ];
  }
}
