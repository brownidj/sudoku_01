import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/board_painter.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key, required this.controller});

  final SudokuController controller;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final Map<String, Map<int, ui.Image>> _animalImages = {};
  ui.Image? _pencilImage;
  Future<void>? _animalLoad;
  OverlayEntry? _tooltipEntry;
  List<int> _candidateDigits = const [];
  Coord? _candidateCoord;
  bool _showCandidates = false;

  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
  }

  @override
  void dispose() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
    super.dispose();
  }

  Future<void> _loadAnimalImages() async {
    final images = await AnimalImageCache.loadAll();
    _animalImages
      ..clear()
      ..addAll(images);
    try {
      final data = await rootBundle.load('assets/images/icons/pencil-icon.png');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _pencilImage = frame.image;
    } catch (_) {
      _pencilImage = null;
    }
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
              child: Text('Animal Sudoku'),
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
                  const DrawerHeader(
                    child: Text('Animal Sudoku'),
                  ),
                  const ListTile(
                    title: Text('Animal Style'),
                  ),
                  RadioListTile<String>(
                    title: const Text('Cute'),
                    value: 'cute',
                    groupValue: state.animalStyle,
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
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.onAnimalStyleChanged(value);
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
                        final boardSize = min(constraints.maxWidth, constraints.maxHeight);
                        return Align(
                          alignment: Alignment.topCenter,
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
                              onLongPressStart: (details) {
                                final local = details.localPosition;
                                final layout = layoutForSize(Size(boardSize, boardSize));
                                final coord = _coordFromOffset(layout, local);
                                if (coord != null) {
                                  _handleCellLongPress(details.globalPosition, coord);
                                }
                              },
                              child: CustomPaint(
                                painter: SudokuBoardPainter(
                                  state: state,
                                  style: style,
                                  animalImages: _animalImages[state.animalStyle] ?? const {},
                                  pencilImage: _pencilImage,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildCandidatePanel(state, style),
                if (state.gameOver) Legend(style: style),
                ActionBar(
                  state: state,
                  onToggleNotesMode: widget.controller.onToggleNotesMode,
                  onClear: widget.controller.onClearPressed,
                  onCheckOrSolution: () {
                    setState(() {
                      _showCandidates = false;
                      _candidateDigits = const [];
                      _candidateCoord = null;
                    });
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
    if (_animalLoad != null) {
      await _animalLoad;
    }
    final candidates = _possibleDigits(state, coord);
    final withClear = [...candidates, 0];
    if (!mounted) {
      return;
    }
    setState(() {
      _showCandidates = true;
      _candidateDigits = withClear;
      _candidateCoord = coord;
    });
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
    left = left.clamp(tooltipMargin, size.width - tooltipSize.width - tooltipMargin);
    top = top.clamp(tooltipMargin, size.height - tooltipSize.height - tooltipMargin);

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

  Widget _animalOption(int digit, GlobalKey<TooltipState> tooltipKey) {
    if (digit == 0) {
      return const Icon(Icons.clear);
    }
    final style = widget.controller.state.animalStyle;
    final image = _animalImages[style]?[digit];
    if (image == null) {
      return Text('$digit');
    }
    final name = AnimalImageCache.nameForDigit(digit);
    return Tooltip(
      key: tooltipKey,
      message: name,
      triggerMode: TooltipTriggerMode.manual,
      child: SizedBox(
        width: 32,
        height: 32,
        child: FittedBox(
          fit: BoxFit.contain,
          child: RawImage(image: image),
        ),
      ),
    );
  }

  Widget _buildCandidatePanel(UiState state, BoardStyle style) {
    if (!_showCandidates || _candidateCoord == null || state.gameOver) {
      return const SizedBox.shrink();
    }
    final showAnimals = state.contentMode == 'animals';
    final selectedNotes = _selectedNotes(state);
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
          for (final digit in _candidateDigits)
            Builder(
              builder: (context) {
                final tooltipKey = GlobalKey<TooltipState>();
                return SizedBox(
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onLongPress:
                        showAnimals ? () => tooltipKey.currentState?.ensureTooltipVisible() : null,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: state.notesMode && selectedNotes.contains(digit)
                            ? const Color(0xFFF6BABA)
                            : (showAnimals ? Colors.white : null),
                      ),
                      onPressed: () {
                        if (digit == 0) {
                          widget.controller.onClearPressed();
                        } else {
                          widget.controller.onDigitPressed(digit);
                        }
                        if (!state.notesMode || digit == 0) {
                          setState(() {
                            _showCandidates = false;
                            _candidateDigits = const [];
                            _candidateCoord = null;
                          });
                        } else {
                          setState(() {});
                        }
                      },
                      child: showAnimals
                          ? _animalOption(digit, tooltipKey)
                          : (digit == 0 ? const Icon(Icons.clear) : Text('$digit')),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Set<int> _selectedNotes(UiState state) {
    final coord = _candidateCoord;
    if (coord == null) {
      return {};
    }
    return state.board.cells[coord.row][coord.col].notes.toSet();
  }

}
