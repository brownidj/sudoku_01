import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';
import 'package:flutter_app/ui/widgets/victory_foil_overlay.dart';
import 'package:flutter_app/ui/widgets/victory_mascot_overlay.dart';

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
  final GlobalKey bottomControlsKey;
  final VoidCallback onNewGame;
  final ValueChanged<String> onContentModeChanged;
  final ValueChanged<String> onPuzzleModeChanged;
  final ValueChanged<String> onSetDifficulty;
  final ValueChanged<String> onStyleChanged;
  final VoidCallback onUndo;
  final VoidCallback onToggleNotesMode;
  final VoidCallback onClear;
  final VoidCallback onCheckOrSolution;
  final bool showVictoryOverlay;
  final String? victoryAssetPath;
  final double? victoryImageCenterY;

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
    required this.bottomControlsKey,
    required this.onNewGame,
    required this.onContentModeChanged,
    required this.onPuzzleModeChanged,
    required this.onSetDifficulty,
    required this.onStyleChanged,
    required this.onUndo,
    required this.onToggleNotesMode,
    required this.onClear,
    required this.onCheckOrSolution,
    required this.showVictoryOverlay,
    required this.victoryAssetPath,
    required this.victoryImageCenterY,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        key: overlayStackKey,
        children: [
          Column(
            children: [
              TopControls(
                state: state,
                onNewGame: onNewGame,
                onContentModeChanged: onContentModeChanged,
                onStyleChanged: onStyleChanged,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: SudokuBoardArea(
                    key: tilesPanelKey,
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
              if (state.gameOver) Legend(style: style),
              KeyedSubtree(
                key: bottomControlsKey,
                child: ActionBar(
                  state: state,
                  onUndo: onUndo,
                  onToggleNotesMode: onToggleNotesMode,
                  onClear: onClear,
                  onCheckOrSolution: onCheckOrSolution,
                ),
              ),
            ],
          ),
          if (showVictoryOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    const Positioned.fill(child: VictoryFoilOverlay()),
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
