import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';
import 'package:flutter_app/ui/widgets/victory_autumn_leaves_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_confetti_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_foil_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_mascot_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_star_overlay.dart';

class SudokuGameContent extends StatelessWidget {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;
  final bool candidateVisible;
  final List<int> candidateDigits;
  final Set<int> selectedNotes;
  final ValueChanged<int> onDigitSelected;
  final ValueChanged<int>? onDigitLongPressed;
  final Future<void> Function(Coord coord) onTapCell;
  final void Function(Offset globalPosition, Coord coord) onLongPressCell;
  final bool showDebugNotification;
  final GlobalKey overlayStackKey;
  final GlobalKey tilesPanelKey;
  final GlobalKey boardKey;
  final GlobalKey bottomControlsKey;
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
  final VoidCallback onNewGamePressed;
  final bool showVictoryOverlay;
  final String? victoryAssetPath;
  final double? victoryImageCenterY;
  final PremiumCelebrationStyle? premiumCelebrationStyle;

  const SudokuGameContent({
    super.key,
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
    required this.candidateVisible,
    required this.candidateDigits,
    required this.selectedNotes,
    required this.onDigitSelected,
    required this.onDigitLongPressed,
    required this.onTapCell,
    required this.onLongPressCell,
    required this.showDebugNotification,
    required this.overlayStackKey,
    required this.tilesPanelKey,
    required this.boardKey,
    required this.bottomControlsKey,
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
    required this.onNewGamePressed,
    required this.showVictoryOverlay,
    required this.victoryAssetPath,
    required this.victoryImageCenterY,
    required this.premiumCelebrationStyle,
  });

  @override
  Widget build(BuildContext context) {
    final premiumCelebrationEnabled = state.premiumActive;
    final selectedCelebrationStyle = !premiumCelebrationEnabled
        ? PremiumCelebrationStyle.foil
        : (premiumCelebrationStyle ?? PremiumCelebrationStyle.foil);
    return SafeArea(
      top: false,
      child: Stack(
        key: overlayStackKey,
        children: [
          Column(
            children: [
              TopControls(
                state: state,
                onProgressPressed: onProgressPressed,
                onHelpPressed: onHelpPressed,
                onContentModeChanged: onContentModeChanged,
                onConfigurationLockTapped: onConfigurationLockTapped,
                onConfigurationLockDoubleTapped:
                    onConfigurationLockDoubleTapped,
                onStyleChanged: onStyleChanged,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                  child: SudokuBoardArea(
                    key: tilesPanelKey,
                    boardKey: boardKey,
                    state: state,
                    style: style,
                    animalImages: animalImages,
                    noteImagesBySize: noteImagesBySize,
                    devicePixelRatio: devicePixelRatio,
                    candidateVisible: candidateVisible,
                    candidateDigits: candidateDigits,
                    selectedNotes: selectedNotes,
                    onDigitSelected: onDigitSelected,
                    onDigitLongPressed: onDigitLongPressed,
                    onTapCell: onTapCell,
                    onLongPressCell: onLongPressCell,
                    showDebugNotification: showDebugNotification,
                    onPuzzleModeChanged: onPuzzleModeChanged,
                    onDifficultyChanged: onSetDifficulty,
                  ),
                ),
              ),
              KeyedSubtree(
                key: bottomControlsKey,
                child: ActionBar(
                  state: state,
                  onUndo: onUndo,
                  onToggleNotesMode: onToggleNotesMode,
                  onClear: onClear,
                  onCheckOrSolution: onCheckOrSolution,
                  onNewGamePressed: onNewGamePressed,
                  showNewGame: true,
                ),
              ),
            ],
          ),
          if (showVictoryOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    if (selectedCelebrationStyle ==
                        PremiumCelebrationStyle.foil)
                      const Positioned.fill(child: VictoryFoilOverlay()),
                    if (selectedCelebrationStyle ==
                        PremiumCelebrationStyle.stars)
                      const Positioned.fill(child: VictoryStarOverlay()),
                    if (selectedCelebrationStyle ==
                        PremiumCelebrationStyle.confetti)
                      const Positioned.fill(child: VictoryConfettiOverlay()),
                    if (selectedCelebrationStyle ==
                        PremiumCelebrationStyle.autumnLeaves)
                      const Positioned.fill(
                        child: VictoryAutumnLeavesOverlay(),
                      ),
                    Positioned.fill(
                      child: VictoryMascotOverlay(
                        assetPath: victoryAssetPath,
                        centerY: victoryImageCenterY,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
