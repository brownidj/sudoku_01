import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';

class SudokuScreenViewModel {
  final bool candidateVisible;
  final List<int> candidateDigits;
  final Set<int> selectedNotes;
  final bool showDebugTools;
  final bool showDebugNotification;

  const SudokuScreenViewModel({
    required this.candidateVisible,
    required this.candidateDigits,
    required this.selectedNotes,
    required this.showDebugTools,
    required this.showDebugNotification,
  });

  factory SudokuScreenViewModel.from({
    required UiState state,
    required CandidatePanelCoordinator coordinator,
    required CandidateSelectionService selectionService,
    required bool debugToolsEnabled,
  }) {
    final candidateCoord = coordinator.candidateCoord;
    final showDebug = AppDebug.enabled && debugToolsEnabled;
    return SudokuScreenViewModel(
      candidateVisible:
          coordinator.visible && candidateCoord != null && !state.gameOver,
      candidateDigits: coordinator.candidateDigits,
      selectedNotes: selectionService.selectedNotes(state),
      showDebugTools: showDebug,
      showDebugNotification: showDebug,
    );
  }
}
