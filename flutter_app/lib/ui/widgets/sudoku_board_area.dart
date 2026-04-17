import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_metadata_row.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardArea extends StatelessWidget {
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
  final ValueChanged<Coord> onTapCell;
  final void Function(Offset, Coord) onLongPressCell;
  final bool showDebugNotification;
  final ValueChanged<String>? onPuzzleModeChanged;
  final ValueChanged<String>? onDifficultyChanged;

  const SudokuBoardArea({
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
    this.showDebugNotification = true,
    this.onPuzzleModeChanged,
    this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final correctionLimit = correctionsForDifficulty(state.difficulty);
    final correctionsTooltipMessage =
        'You have $correctionLimit corrections available for this puzzle. '
        'If an earlier move blocks progress, use one correction to keep going '
        'at your own pace.';
    const hintsTooltipMessage =
        'Hints mark conflicts in the same row, column, or 3x3 box. '
        'Use them anytime to support steady progress.';
    const startInstructionMessage =
        'To start, select a square you want to add an icon to.';
    return LayoutBuilder(
      builder: (context, constraints) {
        const candidateButtonSize = 52.0;
        const candidateSpacing = 8.0;
        const candidateHorizontalPadding = 16.0;
        const candidateVerticalPadding = 12.0;
        const gapBeforeCandidate = 12.0;
        final debugBannerHeight =
            (showDebugNotification && state.debugScenarioLabel != null)
            ? 42.0
            : 0.0;
        const metadataRowHeight = 44.0;
        final metadataHeight =
            6.0 +
            debugBannerHeight +
            (debugBannerHeight > 0 ? 6.0 : 0.0) +
            metadataRowHeight;
        final candidatePanelWidth = max(
          0.0,
          constraints.maxWidth - (candidateHorizontalPadding * 2),
        );
        final maxControls = candidateDigits.length;
        final controlsPerRow = maxControls == 0
            ? 1
            : ((candidatePanelWidth + candidateSpacing) /
                      (candidateButtonSize + candidateSpacing))
                  .floor()
                  .clamp(1, maxControls);
        final rowCount = maxControls == 0
            ? 0
            : ((maxControls + controlsPerRow - 1) / controlsPerRow).floor();
        final candidatePanelHeight = candidateVisible
            ? (candidateVerticalPadding * 2) +
                  (candidateButtonSize * rowCount) +
                  (candidateSpacing * max(0, rowCount - 1))
            : 0.0;
        final candidateHeight = candidateVisible
            ? gapBeforeCandidate + candidatePanelHeight
            : 0.0;
        final showStartInstruction = state.selected == null && !state.gameOver;
        const instructionBubbleHeight = 54.0;
        const gapBeforeInstruction = 8.0;
        final instructionHeight = showStartInstruction
            ? instructionBubbleHeight + gapBeforeInstruction
            : 0.0;
        const layoutSafetyPadding = 8.0;
        final reservedHeight =
            metadataHeight +
            instructionHeight +
            candidateHeight +
            layoutSafetyPadding;
        final maxBoard = max(0.0, constraints.maxHeight - reservedHeight);
        final boardWidth = max(0.0, min(constraints.maxWidth, maxBoard));
        final cellWidth = boardWidth / 9.0;
        AppDebug.log(
          'Board: ${boardWidth.toStringAsFixed(2)} lp, '
          'Cell: ${cellWidth.toStringAsFixed(2)} lp '
          '(${(cellWidth * devicePixelRatio).toStringAsFixed(0)} px @ dpr=$devicePixelRatio)',
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: boardWidth,
              height: boardWidth,
              child: SudokuBoard(
                state: state,
                style: style,
                animalImages: animalImages,
                noteImagesBySize: noteImagesBySize,
                devicePixelRatio: devicePixelRatio,
                onTapCell: onTapCell,
                onLongPressCell: onLongPressCell,
              ),
            ),
            const SizedBox(height: 6),
            if (showDebugNotification && state.debugScenarioLabel != null) ...[
              SizedBox(
                width: boardWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.debugScenarioLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            SizedBox(
              width: boardWidth,
              child: SudokuBoardMetadataRow(
                state: state,
                hintsTooltipMessage: hintsTooltipMessage,
                correctionsTooltipMessage: correctionsTooltipMessage,
                onPuzzleModeChanged: onPuzzleModeChanged,
                onDifficultyChanged: onDifficultyChanged,
              ),
            ),
            if (showStartInstruction) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: boardWidth,
                child: _InlineTooltipMessage(message: startInstructionMessage),
              ),
            ],
            const SizedBox(height: 12),
            CandidatePanel(
              visible: candidateVisible,
              candidateDigits: candidateDigits,
              showImages: state.contentMode != 'numbers',
              contentMode: state.contentMode,
              notesMode: state.notesMode,
              selectedNotes: selectedNotes,
              animalImages: animalImages,
              onDigitSelected: onDigitSelected,
              onDigitLongPressed: onDigitLongPressed,
            ),
          ],
        );
      },
    );
  }
}

class _InlineTooltipMessage extends StatelessWidget {
  final String message;

  const _InlineTooltipMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final tooltipTheme = Theme.of(context).tooltipTheme;
    return Container(
      padding:
          tooltipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: tooltipTheme.margin,
      decoration:
          tooltipTheme.decoration ??
          BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
      child: Text(
        message,
        style:
            tooltipTheme.textStyle ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
