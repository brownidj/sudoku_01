import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';

class CandidatePanelCoordinator {
  final CandidateSelectionService selectionService;

  CandidatePanelCoordinator(this.selectionService);

  bool get visible => selectionService.visible;
  List<int> get candidateDigits => selectionService.candidateDigits;
  Coord? get candidateCoord => selectionService.candidateCoord;

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
    selectionService.show(coord, [...candidates, 0]);
  }

  void onDigitApplied({required int digit, required UiState nextState}) {
    final candidateCoord = selectionService.candidateCoord;
    final selectedCellConflicted =
        candidateCoord != null &&
        nextState
            .board
            .cells[candidateCoord.row][candidateCoord.col]
            .conflicted;
    if ((digit != 0 && selectedCellConflicted) ||
        (nextState.notesMode && digit != 0)) {
      selectionService.refresh();
      return;
    }
    if (digit == 0 || !nextState.notesMode) {
      selectionService.hide();
      return;
    }
    selectionService.refresh();
  }

  void onPlacedDigitViaLongPress() {
    selectionService.hide();
  }

  void onCheckOrSolution() {
    selectionService.hide();
  }

  void onCorrectionConfirmed() {
    selectionService.hide();
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
