import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ui.Image? _pencilImage;
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
                    child: SudokuBoard(
                      state: state,
                      style: style,
                      animalImages: _animalImages[state.animalStyle] ?? const {},
                      pencilImage: _pencilImage,
                      onTapCell: _handleCellTap,
                      onLongPressCell: _handleCellLongPress,
                    ),
                  ),
                ),
                CandidatePanel(
                  visible: _candidateController.visible &&
                      _candidateController.candidateCoord != null &&
                      !state.gameOver,
                  candidateDigits: _candidateController.candidateDigits,
                  showAnimals: state.contentMode == 'animals',
                  notesMode: state.notesMode,
                  selectedNotes: _selectedNotes(state),
                  animalImages: _animalImages[state.animalStyle] ?? const {},
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
    if (_animalLoad != null) {
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

  Set<int> _selectedNotes(UiState state) {
    final coord = _candidateController.candidateCoord;
    if (coord == null) {
      return {};
    }
    return state.board.cells[coord.row][coord.col].notes.toSet();
  }

}
