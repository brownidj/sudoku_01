import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final correctionLimit = correctionsForDifficulty(state.difficulty);
    final correctionsTooltipMessage =
        'In this mode you have $correctionLimit corrections opportunities. '
        'When you select a tile that has no valid solution, because of an '
        'earlier error, a box will open that allows you to use an automatic '
        'correction.';
    return LayoutBuilder(
      builder: (context, constraints) {
        final debugBannerHeight =
            (showDebugNotification && state.debugScenarioLabel != null)
            ? 42.0
            : 0.0;
        final metadataHeight =
            6.0 +
            debugBannerHeight +
            (debugBannerHeight > 0 ? 6.0 : 0.0) +
            20.0;
        final candidateHeight = candidateVisible ? (15.0 + 68.0) : 0.0;
        final reservedHeight = metadataHeight + 12.0 + candidateHeight;
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
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.puzzleMode.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Builder(
                          builder: (context) {
                            final tooltipKey = GlobalKey<TooltipState>();
                            return Tooltip(
                              key: tooltipKey,
                              message: correctionsTooltipMessage,
                              triggerMode: TooltipTriggerMode.manual,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onLongPress: () => tooltipKey.currentState
                                    ?.ensureTooltipVisible(),
                                child: Text(
                                  '${state.correctionsLeft} auto-corrects left',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.difficulty.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
