import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/board_painter.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key, required this.controller});

  final SudokuController controller;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final Map<int, ui.Image> _animalImages = {};
  Future<void>? _animalLoad;

  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
  }

  Future<void> _loadAnimalImages() async {
    final images = await AnimalImageCache.load();
    _animalImages
      ..clear()
      ..addAll(images);
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
            title: const Text('Sudoku'),
            actions: [
              IconButton(
                onPressed: () => widget.controller.onSaveRequested(context),
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save',
              ),
              IconButton(
                onPressed: () => widget.controller.onLoadRequested(context),
                icon: const Icon(Icons.upload_file_outlined),
                tooltip: 'Load',
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopControls(state),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = min(constraints.maxWidth, constraints.maxHeight);
                        return Center(
                          child: SizedBox(
                            width: boardSize,
                            height: boardSize,
                            child: GestureDetector(
                              onTapDown: (details) {
                                final local = details.localPosition;
                                final layout = layoutForSize(Size(boardSize, boardSize));
                                final coord = _coordFromOffset(layout, local);
                                if (coord != null) {
                                  _handleCellTap(coord);
                                }
                              },
                              child: CustomPaint(
                                painter: SudokuBoardPainter(
                                  state: state,
                                  style: style,
                                  animalImages: _animalImages,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildStatusBar(state, style),
                _buildActionBar(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls(UiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: widget.controller.onNewGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
          ToggleButtons(
            isSelected: [state.contentMode == 'numbers', state.contentMode == 'animals'],
            onPressed: (index) {
              widget.controller.onContentModeChanged(index == 1 ? 'animals' : 'numbers');
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Numbers'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Animals'),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Difficulty'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: state.difficulty,
                onChanged: state.canChangeDifficulty
                    ? (value) {
                        if (value != null) {
                          widget.controller.onSetDifficulty(value);
                        }
                      }
                    : null,
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Style'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: state.styleName,
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.onStyleChanged(value);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'Modern', child: Text('Modern')),
                  DropdownMenuItem(value: 'Classic', child: Text('Classic')),
                  DropdownMenuItem(value: 'High Contrast', child: Text('High Contrast')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(UiState state, BoardStyle style) {
    final text = state.solved ? 'Solved.' : state.statusText;
    return Container(
      width: double.infinity,
      color: style.statusBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildActionBar(UiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: widget.controller.onToggleNotesMode,
              child: Text(state.notesMode ? 'Notes: On' : 'Notes: Off'),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: widget.controller.onClearPressed,
              child: const Text('Clear'),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: state.canUndo ? widget.controller.onUndo : null,
              child: const Text('Undo'),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: state.canRedo ? widget.controller.onRedo : null,
              child: const Text('Redo'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCellTap(Coord coord) async {
    widget.controller.onCellTapped(coord);
    final state = widget.controller.state;
    final cell = state.board.cells[coord.row][coord.col];
    if (cell.given || cell.value != null) {
      return;
    }
    if (_animalLoad != null) {
      await _animalLoad;
    }
    final candidates = _possibleDigits(state, coord);
    if (candidates.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available numbers for this cell.')),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final showAnimals = state.contentMode == 'animals';
        return AlertDialog(
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final digit in candidates)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => Navigator.of(dialogContext).pop(digit),
                    child: showAnimals
                        ? _animalOption(digit, state.contentMode == 'animals')
                        : Text('$digit'),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      widget.controller.onDigitPressed(selected);
    }
  }

  Coord? _coordFromOffset(BoardLayout layout, Offset offset) {
    final x = offset.dx;
    final y = offset.dy;
    if (x < layout.originX || y < layout.originY) {
      return null;
    }
    final relX = x - layout.originX;
    final relY = y - layout.originY;
    if (relX < 0 || relY < 0 || relX >= layout.boardSize || relY >= layout.boardSize) {
      return null;
    }
    final col = relX ~/ layout.cellSize;
    final row = relY ~/ layout.cellSize;
    if (row < 0 || row > 8 || col < 0 || col > 8) {
      return null;
    }
    return Coord(row, col);
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

  Widget _animalOption(int digit, bool showAnimals) {
    if (!showAnimals) {
      return Text('$digit');
    }
    final image = _animalImages[digit];
    if (image == null) {
      return Text('$digit');
    }
    return SizedBox(
      width: 32,
      height: 32,
      child: FittedBox(
        fit: BoxFit.contain,
        child: RawImage(image: image),
      ),
    );
  }
}
