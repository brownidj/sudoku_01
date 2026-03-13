import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/correction_prompt_service.dart';
import 'package:flutter_app/ui/services/debug_toggle_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/help_dialog.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
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
  final AnimalAssetService _animalAssetService = const AnimalAssetService();
  final CorrectionPromptService _correctionPromptService =
      CorrectionPromptService();
  final DebugToggleService _debugToggleService = DebugToggleService();
  final TooltipOverlayService _tooltipService = TooltipOverlayService();
  Future<void>? _animalLoad;
  late final CandidateSelectionService _candidateSelectionService;
  late final CandidatePanelCoordinator _candidatePanelCoordinator;
  bool _debugToolsEnabled = false;

  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
    _candidateSelectionService = CandidateSelectionService();
    _candidatePanelCoordinator = CandidatePanelCoordinator(
      _candidateSelectionService,
    );
    _candidateSelectionService.addListener(_onCandidateChanged);
  }

  @override
  void dispose() {
    _candidateSelectionService.removeListener(_onCandidateChanged);
    _candidateSelectionService.dispose();
    _tooltipService.dispose();
    super.dispose();
  }

  void _onCandidateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAnimalImages() async {
    final bundle = await _animalAssetService.load();
    _animalImages
      ..clear()
      ..addAll(bundle.animalImages);
    _noteImages
      ..clear()
      ..addAll(bundle.noteImages);
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
        _scheduleCorrectionPrompt(state);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onVersionTapped,
                child: const SizedBox(
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('ZuDoKu 0.5.3 build 143'),
                  ),
                ),
              ),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                  tooltip:
                      'Press this to open a drawer. Use the drawer menu to change puzzle solution mode, difficulty, animals, and style.',
                ),
              ),
            ],
          ),
          drawer: SudokuDrawer(
            state: state,
            onPuzzleModeChanged: widget.controller.onPuzzleModeChanged,
            onSetDifficulty: widget.controller.onSetDifficulty,
            onAnimalStyleChanged: widget.controller.onAnimalStyleChanged,
            onStyleChanged: widget.controller.onStyleChanged,
            onHelpPressed: () {
              Navigator.of(context).maybePop();
              showSudokuHelpDialog(context);
            },
            onLoadCorrectionScenario: () {
              Navigator.of(context).maybePop();
              widget.controller.onLoadCorrectionScenario();
            },
            onLoadExhaustedCorrectionScenario: () {
              Navigator.of(context).maybePop();
              widget.controller.onLoadExhaustedCorrectionScenario();
            },
            showDebugTools: kDebugMode && _debugToolsEnabled,
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
                    child: SudokuBoardArea(
                      state: state,
                      style: style,
                      animalImages:
                          _animalImages[state.animalStyle] ?? const {},
                      noteImagesBySize:
                          _noteImages[state.animalStyle] ?? const {},
                      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                      candidateVisible:
                          _candidatePanelCoordinator.visible &&
                          _candidatePanelCoordinator.candidateCoord != null &&
                          !state.gameOver,
                      candidateDigits:
                          _candidatePanelCoordinator.candidateDigits,
                      selectedNotes: _candidateSelectionService.selectedNotes(
                        state,
                      ),
                      onDigitSelected: (digit) {
                        if (digit == 0) {
                          widget.controller.onClearPressed();
                        } else {
                          widget.controller.onDigitPressed(digit);
                        }
                        _candidatePanelCoordinator.onDigitApplied(
                          digit: digit,
                          nextState: widget.controller.state,
                        );
                      },
                      onDigitLongPressed: state.notesMode
                          ? (digit) {
                              if (digit == 0) {
                                return;
                              }
                              widget.controller.onPlaceDigit(digit);
                              _candidatePanelCoordinator
                                  .onPlacedDigitViaLongPress();
                            }
                          : null,
                      onTapCell: _handleCellTap,
                      onLongPressCell: _handleCellLongPress,
                      showDebugNotification: kDebugMode && _debugToolsEnabled,
                    ),
                  ),
                ),
                if (state.gameOver) Legend(style: style),
                ActionBar(
                  state: state,
                  onUndo: widget.controller.onUndo,
                  onToggleNotesMode: widget.controller.onToggleNotesMode,
                  onClear: widget.controller.onClearPressed,
                  onCheckOrSolution: () => _handleCheckOrSolution(state),
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
    if (state.contentMode == 'numbers') {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    final value = cell.value;
    if (value == null) {
      return;
    }
    final name = AnimalImageCache.displayNameForDigit(state.contentMode, value);
    _tooltipService.show(
      context: context,
      globalPosition: globalPosition,
      text: name,
    );
  }

  Future<void> _handleCellTap(Coord coord) async {
    widget.controller.onCellTapped(coord);
    final state = widget.controller.state;
    await _candidatePanelCoordinator.onCellTapped(
      state: state,
      coord: coord,
      animalLoad: _animalLoad,
      setNotesMode: widget.controller.setNotesMode,
    );
    if (!mounted) {
      return;
    }
  }

  void _handleCheckOrSolution(UiState state) {
    _candidatePanelCoordinator.onCheckOrSolution();
    if (state.gameOver) {
      widget.controller.onShowSolution();
      return;
    }
    widget.controller.onCheckSolution();
  }

  void _scheduleCorrectionPrompt(UiState state) {
    if (!_correctionPromptService.shouldSchedule(state.correctionPromptCoord)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showCorrectionPrompt();
    });
  }

  Future<void> _showCorrectionPrompt() async {
    final useCorrection = await _correctionPromptService.showPrompt(context);
    if (!mounted) {
      return;
    }
    if (useCorrection) {
      widget.controller.onConfirmCorrection();
      _candidatePanelCoordinator.onCorrectionConfirmed();
      return;
    }
    widget.controller.onDismissCorrectionPrompt();
  }

  void _onVersionTapped() {
    if (kReleaseMode) {
      return;
    }
    if (!_debugToggleService.registerVersionTap(DateTime.now())) {
      return;
    }
    setState(() {
      _debugToolsEnabled = !_debugToolsEnabled;
    });
  }
}
