import 'package:flutter/material.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/controllers/sudoku_screen_interaction_controller.dart';
import 'package:flutter_app/ui/services/debug_toggle_service.dart';
import 'package:flutter_app/ui/services/sudoku_cell_tooltip_service.dart';
import 'package:flutter_app/ui/services/sudoku_controller_binding_service.dart';
import 'package:flutter_app/ui/services/sudoku_correction_flow_coordinator.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_coordinator.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_service.dart';
import 'package:flutter_app/ui/services/sudoku_tile_preview_audio_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_audio_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_layout_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_position_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';

class SudokuScreenServiceRegistry {
  late final CandidateSelectionService candidateSelectionService;
  late final CandidatePanelCoordinator candidatePanelCoordinator;
  late final DebugToggleService debugToggleService;
  late final TooltipOverlayService tooltipService;
  late final SudokuTilePreviewAudioService tilePreviewAudioService;
  late final SudokuCellTooltipService cellTooltipService;
  late final SudokuScreenEffectsService effectsService;
  late final SudokuScreenEffectsCoordinator effectsCoordinator;
  late final SudokuCorrectionFlowCoordinator correctionFlowCoordinator;
  late final SudokuVictoryOverlayService victoryOverlayService;
  late final SudokuVictoryAudioService victoryAudioService;
  late final SudokuVictoryPositionService victoryPositionService;
  late final SudokuControllerBindingService controllerBindingService;

  final VoidCallback _onVictoryOverlayChanged;

  late SudokuScreenInteractionController interactionController;

  SudokuScreenServiceRegistry({
    required SudokuController controller,
    required VoidCallback onControllerChanged,
    required VoidCallback onVictoryOverlayChanged,
  }) : _onVictoryOverlayChanged = onVictoryOverlayChanged {
    candidateSelectionService = CandidateSelectionService();
    candidatePanelCoordinator = CandidatePanelCoordinator(
      candidateSelectionService,
    );
    debugToggleService = DebugToggleService();
    tooltipService = TooltipOverlayService();
    tilePreviewAudioService = SudokuTilePreviewAudioService();
    cellTooltipService = SudokuCellTooltipService(
      tooltipService,
      tilePreviewAudioService,
    );
    effectsService = SudokuScreenEffectsService();
    effectsCoordinator = SudokuScreenEffectsCoordinator(effectsService);
    correctionFlowCoordinator = SudokuCorrectionFlowCoordinator(effectsService);
    victoryOverlayService = SudokuVictoryOverlayService();
    victoryAudioService = SudokuVictoryAudioService();
    victoryPositionService = SudokuVictoryPositionService(
      const SudokuVictoryLayoutService(),
    );
    controllerBindingService = SudokuControllerBindingService(
      controller: controller,
      onChanged: onControllerChanged,
    );

    interactionController = SudokuScreenInteractionController(
      sudokuController: controller,
      candidatePanelCoordinator: candidatePanelCoordinator,
      debugToggleService: debugToggleService,
    );

    victoryOverlayService.state.addListener(_onVictoryOverlayChanged);
    controllerBindingService.attach();
  }

  void updateController(SudokuController controller) {
    controllerBindingService.updateController(controller);
    interactionController = SudokuScreenInteractionController(
      sudokuController: controller,
      candidatePanelCoordinator: candidatePanelCoordinator,
      debugToggleService: debugToggleService,
    );
  }

  void onControllerChanged({
    required BuildContext context,
    required UiState state,
    required bool Function() isMounted,
    required Future<void> Function() showCorrectionPrompt,
  }) {
    victoryOverlayService.onUiStateChanged(state);
    effectsCoordinator.onStateChanged(
      context: context,
      state: state,
      isMounted: isMounted,
      showCorrectionPrompt: showCorrectionPrompt,
      showCorrectionNotice: () =>
          effectsService.showCorrectionNotice(context, state),
    );
  }

  void onAudioEnabledChanged(bool enabled) {
    tilePreviewAudioService.setEnabled(enabled);
    victoryAudioService.setEnabled(enabled);
    victoryAudioService.onOverlayStateChanged(
      victoryOverlayService.state.value,
    );
  }

  void onVictoryOverlayChanged({
    required GlobalKey overlayStackKey,
    required GlobalKey tilesPanelKey,
    required GlobalKey bottomControlsKey,
    required bool Function() isMounted,
  }) {
    final victoryState = victoryOverlayService.state.value;
    victoryAudioService.onOverlayStateChanged(victoryState);
    victoryPositionService.onOverlayStateChanged(
      overlayState: victoryState,
      overlayStackKey: overlayStackKey,
      tilesPanelKey: tilesPanelKey,
      bottomControlsKey: bottomControlsKey,
      isMounted: isMounted,
    );
  }

  Future<void> showCorrectionPrompt({
    required BuildContext context,
    required bool Function() isMounted,
    required VoidCallback onConfirmCorrection,
    required VoidCallback onCorrectionConfirmed,
    required VoidCallback onDismissCorrectionPrompt,
    required UiState Function() currentState,
  }) {
    return correctionFlowCoordinator.showPrompt(
      context: context,
      isMounted: isMounted,
      onConfirmCorrection: onConfirmCorrection,
      onCorrectionConfirmed: onCorrectionConfirmed,
      onDismissCorrectionPrompt: onDismissCorrectionPrompt,
      currentState: currentState,
    );
  }

  void showCellTooltip({
    required BuildContext context,
    required UiState state,
    required Coord coord,
    required Offset globalPosition,
  }) {
    cellTooltipService.showForCell(
      context: context,
      state: state,
      coord: coord,
      globalPosition: globalPosition,
    );
  }

  void dispose() {
    controllerBindingService.dispose();
    candidateSelectionService.dispose();
    victoryOverlayService.state.removeListener(_onVictoryOverlayChanged);
    victoryOverlayService.dispose();
    victoryAudioService.dispose();
    tilePreviewAudioService.dispose();
    victoryPositionService.dispose();
    tooltipService.dispose();
  }
}
