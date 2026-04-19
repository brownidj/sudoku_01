import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';
import 'package:flutter_app/ui/widgets/sudoku_game_content.dart';

class SudokuGameContentBuilder extends StatelessWidget {
  const SudokuGameContentBuilder({
    super.key,
    required this.victoryStateListenable,
    required this.victoryCenterYListenable,
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
    required this.viewModel,
    required this.overlayStackKey,
    required this.tilesPanelKey,
    required this.bottomControlsKey,
    required this.onDigitSelected,
    required this.onDigitLongPressed,
    required this.onTapCell,
    required this.onLongPressCell,
    required this.onProgressPressed,
    required this.onHelpPressed,
    required this.onContentModeChanged,
    required this.onConfigurationLockTapped,
    required this.onConfigurationLockDoubleTapped,
    required this.onPuzzleModeChanged,
    required this.onSetDifficulty,
    required this.onStyleChanged,
    required this.onUndo,
    required this.onToggleNotesMode,
    required this.onClear,
    required this.onCheckOrSolution,
  });

  final ValueListenable<VictoryOverlayState> victoryStateListenable;
  final ValueListenable<double?> victoryCenterYListenable;
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;
  final SudokuScreenViewModel viewModel;
  final GlobalKey overlayStackKey;
  final GlobalKey tilesPanelKey;
  final GlobalKey bottomControlsKey;
  final ValueChanged<int> onDigitSelected;
  final ValueChanged<int>? onDigitLongPressed;
  final Future<void> Function(Coord) onTapCell;
  final void Function(Offset, Coord) onLongPressCell;
  final VoidCallback onProgressPressed;
  final VoidCallback onHelpPressed;
  final ValueChanged<String> onContentModeChanged;
  final VoidCallback onConfigurationLockTapped;
  final VoidCallback onConfigurationLockDoubleTapped;
  final ValueChanged<String> onPuzzleModeChanged;
  final ValueChanged<String> onSetDifficulty;
  final ValueChanged<String> onStyleChanged;
  final VoidCallback onUndo;
  final VoidCallback onToggleNotesMode;
  final VoidCallback onClear;
  final VoidCallback onCheckOrSolution;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VictoryOverlayState>(
      valueListenable: victoryStateListenable,
      builder: (context, victoryState, _) {
        return ValueListenableBuilder<double?>(
          valueListenable: victoryCenterYListenable,
          builder: (context, centerY, _) {
            return SudokuGameContent(
              state: state,
              style: style,
              animalImages: animalImages,
              noteImagesBySize: noteImagesBySize,
              devicePixelRatio: devicePixelRatio,
              candidateVisible: viewModel.candidateVisible,
              candidateDigits: viewModel.candidateDigits,
              selectedNotes: viewModel.selectedNotes,
              onDigitSelected: onDigitSelected,
              onDigitLongPressed: onDigitLongPressed,
              onTapCell: onTapCell,
              onLongPressCell: onLongPressCell,
              showDebugNotification: viewModel.showDebugNotification,
              overlayStackKey: overlayStackKey,
              tilesPanelKey: tilesPanelKey,
              bottomControlsKey: bottomControlsKey,
              onProgressPressed: onProgressPressed,
              onHelpPressed: onHelpPressed,
              onContentModeChanged: onContentModeChanged,
              onConfigurationLockTapped: onConfigurationLockTapped,
              onConfigurationLockDoubleTapped: onConfigurationLockDoubleTapped,
              onPuzzleModeChanged: onPuzzleModeChanged,
              onSetDifficulty: onSetDifficulty,
              onStyleChanged: onStyleChanged,
              onUndo: onUndo,
              onToggleNotesMode: onToggleNotesMode,
              onClear: onClear,
              onCheckOrSolution: onCheckOrSolution,
              showVictoryOverlay: victoryState.visible,
              victoryAssetPath: victoryState.assetPath,
              victoryImageCenterY: centerY,
            );
          },
        );
      },
    );
  }
}
