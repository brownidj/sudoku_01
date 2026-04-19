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
        'You have $correctionLimit automatic corrections available for this puzzle. '
        'If an earlier move blocks your progress, you can use a correction to keep going '
        'at your own pace. If you run out of corrections, use Undo.';
    const hintsTooltipMessage =
        'Hints mark conflicts in the same row, column, or 3x3 box. Use them to allow you to progress. Use Undo if you have no more Hints';
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxCandidateControls = 9;
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
        final controlsPerRow =
            ((candidatePanelWidth + candidateSpacing) /
                    (candidateButtonSize + candidateSpacing))
                .floor()
                .clamp(1, maxCandidateControls);
        final rowCount =
            ((maxCandidateControls + controlsPerRow - 1) / controlsPerRow)
                .floor();
        final candidatePanelHeight =
            (candidateVerticalPadding * 2) +
            (candidateButtonSize * rowCount) +
            (candidateSpacing * max(0, rowCount - 1));
        final candidateHeight = gapBeforeCandidate + candidatePanelHeight;
        const layoutSafetyPadding = 9.0;
        final reservedHeight =
            metadataHeight + candidateHeight + layoutSafetyPadding;
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
            const SizedBox(height: 12),
            SizedBox(
              height: candidatePanelHeight,
              child: CandidatePanel(
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
            ),
          ],
        );
      },
    );
  }
}
