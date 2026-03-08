import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/candidate_selection_controller.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key, required this.controller});

  final SudokuController controller;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final Map<String, Map<int, ui.Image>> _animalImages = {};
  final Map<String, Map<int, Map<int, ui.Image>>> _noteImages = {};
  Future<void>? _animalLoad;
  OverlayEntry? _tooltipEntry;
  late final CandidateSelectionController _candidateController;

  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
    _candidateController = CandidateSelectionController()
      ..addListener(_onCandidateChanged);
  }

  @override
  void dispose() {
    _candidateController.removeListener(_onCandidateChanged);
    _candidateController.dispose();
    _tooltipEntry?.remove();
    _tooltipEntry = null;
    super.dispose();
  }

  void _onCandidateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAnimalImages() async {
    final images = await AnimalImageCache.loadAll();
    Map<String, Map<int, Map<int, ui.Image>>> notes = const {};
    try {
      notes = await AnimalImageCache.loadNotesAll();
    } catch (error) {
      debugPrint('Failed to load notes icons: $error');
      notes = const {};
    }
    _animalImages
      ..clear()
      ..addAll(images);
    _noteImages
      ..clear()
      ..addAll(notes);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final style = styleForName(state.styleName);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Align(
              alignment: Alignment.centerLeft,
              child: Text('ZooDoKu 0.4.1'),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ZooDoKu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Puzzle Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final canEdit =
                          state.canChangePuzzleMode &&
                          state.difficulty != 'hard';
                      return Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Unique'),
                            value: 'unique',
                            groupValue: state.puzzleMode,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            onChanged: canEdit
                                ? (value) {
                                    if (value != null) {
                                      widget.controller.onPuzzleModeChanged(
                                        value,
                                      );
                                    }
                                  }
                                : null,
                          ),
                          RadioListTile<String>(
                            title: const Text('Multi'),
                            value: 'multi',
                            groupValue: state.puzzleMode,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            onChanged: canEdit
                                ? (value) {
                                    if (value != null) {
                                      widget.controller.onPuzzleModeChanged(
                                        value,
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Difficulty',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Easy'),
                    value: 'easy',
                    groupValue: state.difficulty,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: state.canChangeDifficulty
                        ? (value) {
                            if (value != null) {
                              widget.controller.onSetDifficulty(value);
                            }
                          }
                        : null,
                  ),
                  RadioListTile<String>(
                    title: const Text('Medium'),
                    value: 'medium',
                    groupValue: state.difficulty,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: state.canChangeDifficulty
                        ? (value) {
                            if (value != null) {
                              widget.controller.onSetDifficulty(value);
                            }
                          }
                        : null,
                  ),
                  RadioListTile<String>(
                    title: const Text('Hard'),
                    value: 'hard',
                    groupValue: state.difficulty,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: state.canChangeDifficulty
                        ? (value) {
                            if (value != null) {
                              widget.controller.onSetDifficulty(value);
                            }
                          }
                        : null,
                  ),
                  const Divider(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Animals',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Cute'),
                    value: 'cute',
                    groupValue: state.animalStyle,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onAnimalStyleChanged(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Simple'),
                    value: 'simple',
                    groupValue: state.animalStyle,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onAnimalStyleChanged(value);
                      }
                    },
                  ),
                  const Divider(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Puzzle Style',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Modern'),
                    value: 'Modern',
                    groupValue: state.styleName,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onStyleChanged(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Classic'),
                    value: 'Classic',
                    groupValue: state.styleName,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onStyleChanged(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('High Contrast'),
                    value: 'High Contrast',
                    groupValue: state.styleName,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onStyleChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                TopControls(
                  state: state,
                  onNewGame: widget.controller.onNewGame,
                  onContentModeChanged: widget.controller.onContentModeChanged,
                  onSetDifficulty: widget.controller.onSetDifficulty,
                  onStyleChanged: widget.controller.onStyleChanged,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final dpr = MediaQuery.of(context).devicePixelRatio;
                        final media = MediaQuery.of(context);
                        final isTablet = media.size.shortestSide >= 600;
                        final showCandidates =
                            _candidateController.visible &&
                            _candidateController.candidateCoord != null &&
                            !state.gameOver;
                        final reservedHeight = isTablet
                            ? (showCandidates ? 15 + 68 : 0)
                            : 0.0;
                        final maxBoard = isTablet
                            ? (constraints.maxHeight - reservedHeight)
                            : constraints.maxHeight;
                        final boardW = isTablet
                            ? max(0.0, min(constraints.maxWidth, maxBoard))
                            : constraints.maxWidth;
                        final cellW = boardW / 9.0;
                        debugPrint(
                          'Board: ${boardW.toStringAsFixed(2)} lp, '
                          'Cell: ${cellW.toStringAsFixed(2)} lp '
                          '(${(cellW * dpr).toStringAsFixed(0)} px @ dpr=$dpr)',
                        );
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: boardW,
                                  height: boardW,
                                  child: SudokuBoard(
                                    state: state,
                                    style: style,
                                    animalImages:
                                        _animalImages[state.animalStyle] ??
                                        const {},
                                    noteImagesBySize:
                                        _noteImages[state.animalStyle] ??
                                        const {},
                                    devicePixelRatio: dpr,
                                    onTapCell: _handleCellTap,
                                    onLongPressCell: _handleCellLongPress,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: boardW,
                              child: Row(
                                children: [
                                  Text(
                                    state.puzzleMode.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          letterSpacing: 0.6,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    state.difficulty.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          letterSpacing: 0.6,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            CandidatePanel(
                              visible: showCandidates,
                              candidateDigits:
                                  _candidateController.candidateDigits,
                              showAnimals: state.contentMode == 'animals',
                              notesMode: state.notesMode,
                              selectedNotes: _selectedNotes(state),
                              animalImages:
                                  _animalImages[state.animalStyle] ?? const {},
                              onDigitSelected: (digit) {
                                if (digit == 0) {
                                  widget.controller.onClearPressed();
                                } else {
                                  widget.controller.onDigitPressed(digit);
                                }
                                if (!state.notesMode || digit == 0) {
                                  _candidateController.hide();
                                } else {
                                  _candidateController.refresh();
                                }
                              },
                              onDigitLongPressed: state.notesMode
                                  ? (digit) {
                                      if (digit == 0) {
                                        return;
                                      }
                                      widget.controller.onPlaceDigit(digit);
                                      _candidateController.hide();
                                    }
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (state.gameOver) Legend(style: style),
                ActionBar(
                  state: state,
                  onToggleNotesMode: widget.controller.onToggleNotesMode,
                  onClear: widget.controller.onClearPressed,
                  onCheckOrSolution: () {
                    _candidateController.hide();
                    if (state.gameOver) {
                      widget.controller.onShowSolution();
                    } else {
                      widget.controller.onCheckSolution();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCellLongPress(Offset globalPosition, Coord coord) {
    final state = widget.controller.state;
    if (state.contentMode != 'animals') {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    final value = cell.value;
    if (value == null) {
      return;
    }
    final name = AnimalImageCache.nameForDigit(value);
    _showTooltip(globalPosition, name);
  }

  Future<void> _handleCellTap(Coord coord) async {
    widget.controller.onCellTapped(coord);
    final state = widget.controller.state;
    if (state.gameOver) {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    if (cell.given) {
      return;
    }
    if (cell.notes.isNotEmpty && !state.notesMode) {
      widget.controller.setNotesMode(true);
    }
    if (state.contentMode == 'animals' && _animalLoad != null) {
      await _animalLoad;
    }
    final candidates = _possibleDigits(state, coord);
    final withClear = [...candidates, 0];
    if (!mounted) {
      return;
    }
    _candidateController.show(coord, withClear);
  }

  List<int> _possibleDigits(UiState state, Coord coord) {
    final used = <int>{};
    final boxRow = (coord.row ~/ 3) * 3;
    final boxCol = (coord.col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r += 1) {
      for (var c = boxCol; c < boxCol + 3; c += 1) {
        final value = state.board.cells[r][c].value;
        if (value != null) {
          used.add(value);
        }
      }
    }
    final candidates = <int>[];
    for (var d = 1; d <= 9; d += 1) {
      if (!used.contains(d)) {
        candidates.add(d);
      }
    }
    return candidates;
  }

  void _showTooltip(Offset globalPosition, String text) {
    _tooltipEntry?.remove();
    final overlay = Overlay.of(context);
    if (overlay == null) {
      return;
    }
    final size = MediaQuery.of(context).size;
    const tooltipPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    const tooltipMargin = 8.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tooltipSize = Size(
      textPainter.width + tooltipPadding.horizontal,
      textPainter.height + tooltipPadding.vertical,
    );

    var left = globalPosition.dx - tooltipSize.width / 2;
    var top = globalPosition.dy - tooltipSize.height - 14;
    left = left.clamp(
      tooltipMargin,
      size.width - tooltipSize.width - tooltipMargin,
    );
    top = top.clamp(
      tooltipMargin,
      size.height - tooltipSize.height - tooltipMargin,
    );

    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: tooltipPadding,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_tooltipEntry!);
    Future.delayed(const Duration(seconds: 2), () {
      _tooltipEntry?.remove();
      _tooltipEntry = null;
    });
  }

  Set<int> _selectedNotes(UiState state) {
    final coord = _candidateController.candidateCoord;
    if (coord == null) {
      return {};
    }
    return state.board.cells[coord.row][coord.col].notes.toSet();
  }
}
