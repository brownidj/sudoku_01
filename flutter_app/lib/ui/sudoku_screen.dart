import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/candidate_selection_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/candidate_panel_coordinator.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/debug_toggle_service.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_service.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/help_dialog.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';
import 'package:flutter_app/ui/widgets/victory_foil_overlay.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key, required this.controller});

  final SudokuController controller;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _titleTapWindow = Duration(milliseconds: 1200);
  static const Duration _victoryOverlayDuration = Duration(seconds: 10);
  static const List<String> _victoryCartoonAssets = <String>[
    'assets/images/animals_chatGpT/1_cartoon_ape.png',
    'assets/images/animals_chatGpT/2_cartoon_buffalo.png',
    'assets/images/animals_chatGpT/3_cartoon_camel.png',
    'assets/images/animals_chatGpT/4_cartoon_dolphin.png',
    'assets/images/animals_chatGpT/5_cartoon_elephant.png',
    'assets/images/animals_chatGpT/6_cartoon_frog.png',
    'assets/images/animals_chatGpT/7_cartoon_giraffe.png',
    'assets/images/animals_chatGpT/8_cartoon_hippo.png',
    'assets/images/animals_chatGpT/9_cartoon_iguana.png',
  ];

  final Map<String, Map<int, ui.Image>> _animalImages = {};
  final Map<String, Map<int, Map<int, ui.Image>>> _noteImages = {};
  final AnimalAssetService _animalAssetService = const AnimalAssetService();
  final SudokuScreenEffectsService _effectsService =
      SudokuScreenEffectsService();
  final DebugToggleService _debugToggleService = DebugToggleService();
  final TooltipOverlayService _tooltipService = TooltipOverlayService();
  Future<void>? _animalLoad;
  late final CandidateSelectionService _candidateSelectionService;
  late final CandidatePanelCoordinator _candidatePanelCoordinator;
  final GlobalKey _overlayStackKey = GlobalKey();
  final GlobalKey _tilesPanelKey = GlobalKey();
  final GlobalKey _bottomControlsKey = GlobalKey();
  final math.Random _random = math.Random();
  bool _debugToolsEnabled = false;
  int _versionTapCount = 0;
  DateTime? _lastVersionTapAt;
  Timer? _victoryTimer;
  bool _showVictoryOverlay = false;
  bool _wasPuzzleSolved = false;
  String? _victoryCartoonAsset;
  double? _victoryImageCenterY;
  late final AnimationController _animalSwingController;
  late final Animation<double> _animalSwingAngle;

  @override
  void initState() {
    super.initState();
    _animalSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animalSwingAngle =
        Tween<double>(
          begin: -10 * math.pi / 180,
          end: 10 * math.pi / 180,
        ).animate(
          CurvedAnimation(
            parent: _animalSwingController,
            curve: Curves.easeInOut,
          ),
        );
    _animalLoad = _loadAnimalImages();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _onControllerChanged();
    });
    _candidateSelectionService = CandidateSelectionService();
    _candidatePanelCoordinator = CandidatePanelCoordinator(
      _candidateSelectionService,
    );
    _candidateSelectionService.addListener(_onCandidateChanged);
  }

  @override
  void didUpdateWidget(covariant SudokuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _onControllerChanged();
    });
  }

  @override
  void dispose() {
    _victoryTimer?.cancel();
    _animalSwingController.dispose();
    widget.controller.removeListener(_onControllerChanged);
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

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final state = widget.controller.state;
    _syncVictoryOverlay(state);
    _scheduleCorrectionPrompt(state);
    _scheduleCorrectionNotice(state);
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
        final viewModel = SudokuScreenViewModel.from(
          state: state,
          coordinator: _candidatePanelCoordinator,
          selectionService: _candidateSelectionService,
          debugToolsEnabled: _debugToolsEnabled,
        );
        final style = styleForName(state.styleName);

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
                    child: Text('ZuDoKu 0.6.2 build 159'),
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
            onHelpPressed: _onHelpPressed,
            onLoadCorrectionScenario: _onLoadCorrectionScenario,
            onLoadExhaustedCorrectionScenario:
                _onLoadExhaustedCorrectionScenario,
            showDebugTools: viewModel.showDebugTools,
          ),
          body: SafeArea(
            child: Stack(
              key: _overlayStackKey,
              children: [
                Column(
                  children: [
                    TopControls(
                      state: state,
                      onNewGame: widget.controller.onNewGame,
                      onContentModeChanged:
                          widget.controller.onContentModeChanged,
                      onSetDifficulty: widget.controller.onSetDifficulty,
                      onStyleChanged: widget.controller.onStyleChanged,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SudokuBoardArea(
                          key: _tilesPanelKey,
                          state: state,
                          style: style,
                          animalImages:
                              _animalImages[state.animalStyle] ?? const {},
                          noteImagesBySize:
                              _noteImages[state.animalStyle] ?? const {},
                          devicePixelRatio: MediaQuery.of(
                            context,
                          ).devicePixelRatio,
                          candidateVisible: viewModel.candidateVisible,
                          candidateDigits: viewModel.candidateDigits,
                          selectedNotes: viewModel.selectedNotes,
                          onDigitSelected: _onCandidateDigitSelected,
                          onDigitLongPressed: state.notesMode
                              ? _onCandidateDigitLongPressed
                              : null,
                          onTapCell: _handleCellTap,
                          onLongPressCell: _handleCellLongPress,
                          showDebugNotification:
                              viewModel.showDebugNotification,
                        ),
                      ),
                    ),
                    if (state.gameOver) Legend(style: style),
                    KeyedSubtree(
                      key: _bottomControlsKey,
                      child: ActionBar(
                        state: state,
                        onUndo: widget.controller.onUndo,
                        onToggleNotesMode: widget.controller.onToggleNotesMode,
                        onClear: widget.controller.onClearPressed,
                        onCheckOrSolution: _onCheckOrSolutionPressed,
                      ),
                    ),
                  ],
                ),
                if (_showVictoryOverlay)
                  const Positioned.fill(
                    child: IgnorePointer(child: VictoryFoilOverlay()),
                  ),
                if (_showVictoryOverlay && _victoryCartoonAsset != null)
                  Positioned.fill(
                    child: IgnorePointer(child: _buildVictoryCartoon()),
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

  void _onCandidateDigitSelected(int digit) {
    if (digit == 0) {
      widget.controller.onClearPressed();
    } else {
      widget.controller.onDigitPressed(digit);
    }
    _candidatePanelCoordinator.onDigitApplied(
      digit: digit,
      nextState: widget.controller.state,
    );
  }

  void _onCandidateDigitLongPressed(int digit) {
    if (digit == 0) {
      return;
    }
    widget.controller.onPlaceDigit(digit);
    _candidatePanelCoordinator.onPlacedDigitViaLongPress();
  }

  void _onCheckOrSolutionPressed() {
    _handleCheckOrSolution(widget.controller.state);
  }

  void _onHelpPressed() {
    Navigator.of(context).maybePop();
    showSudokuHelpDialog(context);
  }

  void _onLoadCorrectionScenario() {
    Navigator.of(context).maybePop();
    widget.controller.onLoadCorrectionScenario();
  }

  void _onLoadExhaustedCorrectionScenario() {
    Navigator.of(context).maybePop();
    widget.controller.onLoadExhaustedCorrectionScenario();
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
    if (!_effectsService.shouldScheduleCorrectionPrompt(
      state.correctionPromptCoord,
    )) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showCorrectionPrompt();
    });
  }

  void _scheduleCorrectionNotice(UiState state) {
    if (!_effectsService.shouldScheduleCorrectionNotice(
      serial: state.correctionNoticeSerial,
      message: state.correctionNoticeMessage,
    )) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _effectsService.showCorrectionNotice(context, state);
    });
  }

  Future<void> _showCorrectionPrompt() async {
    final useCorrection = await _effectsService.showCorrectionPrompt(context);
    if (!mounted) {
      return;
    }
    if (useCorrection) {
      widget.controller.onConfirmCorrection();
      _candidatePanelCoordinator.onCorrectionConfirmed();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _effectsService.showCorrectionNotice(context, widget.controller.state);
      });
      return;
    }
    widget.controller.onDismissCorrectionPrompt();
  }

  void _onVersionTapped() {
    final now = DateTime.now();
    final previous = _lastVersionTapAt;
    if (previous == null || now.difference(previous) > _titleTapWindow) {
      _versionTapCount = 1;
    } else {
      _versionTapCount += 1;
    }
    _lastVersionTapAt = now;

    if (_versionTapCount >= 3) {
      _versionTapCount = 0;
      _lastVersionTapAt = null;
      _candidatePanelCoordinator.onCheckOrSolution();
      widget.controller.onCompletePuzzleWithSolution();
      return;
    }

    if (!AppDebug.enabled) {
      return;
    }
    if (!_debugToggleService.registerVersionTap(DateTime.now())) {
      return;
    }
    setState(() {
      _debugToolsEnabled = !_debugToolsEnabled;
    });
  }

  void _syncVictoryOverlay(UiState state) {
    if (state.puzzleSolved && !_wasPuzzleSolved) {
      _startVictoryOverlay();
    } else if (!state.puzzleSolved && _showVictoryOverlay) {
      _victoryTimer?.cancel();
      _animalSwingController.stop();
      _showVictoryOverlay = false;
      _victoryCartoonAsset = null;
      _victoryImageCenterY = null;
      setState(() {});
    }
    _wasPuzzleSolved = state.puzzleSolved;
  }

  void _startVictoryOverlay() {
    _victoryTimer?.cancel();
    final asset =
        _victoryCartoonAssets[_random.nextInt(_victoryCartoonAssets.length)];
    setState(() {
      _showVictoryOverlay = true;
      _victoryCartoonAsset = asset;
      _victoryImageCenterY = null;
    });
    _animalSwingController.repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showVictoryOverlay) {
        return;
      }
      final centerY = _victoryMidpointBetweenTilesAndBottomControls();
      if (centerY == null) {
        return;
      }
      setState(() {
        _victoryImageCenterY = centerY;
      });
    });
    _victoryTimer = Timer(_victoryOverlayDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showVictoryOverlay = false;
        _victoryCartoonAsset = null;
        _victoryImageCenterY = null;
      });
      _animalSwingController.stop();
    });
  }

  Widget _buildVictoryCartoon() {
    final centerY = _victoryImageCenterY;
    if (centerY == null) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - 96) / 2;
        final top = centerY - 48 - 115;
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: 96,
              height: 96,
              child: AnimatedBuilder(
                animation: _animalSwingController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animalSwingAngle.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  _victoryCartoonAsset!,
                  key: const ValueKey<String>('victory-cartoon-image'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: top + 96,
              child: const Center(
                child: Text(
                  "Play again! Play again!''",
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontFamilyFallback: <String>['Helvetica', 'sans-serif'],
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double? _victoryMidpointBetweenTilesAndBottomControls() {
    final stackBox =
        _overlayStackKey.currentContext?.findRenderObject() as RenderBox?;
    final tilesBox =
        _tilesPanelKey.currentContext?.findRenderObject() as RenderBox?;
    final controlsBox =
        _bottomControlsKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || tilesBox == null || controlsBox == null) {
      return null;
    }
    final stackTop = stackBox.localToGlobal(Offset.zero).dy;
    final tilesBottom =
        tilesBox.localToGlobal(Offset(0, tilesBox.size.height)).dy - stackTop;
    final controlsBottom =
        controlsBox.localToGlobal(Offset(0, controlsBox.size.height)).dy -
        stackTop;
    if (controlsBottom <= tilesBottom) {
      return tilesBottom;
    }
    return (tilesBottom + controlsBottom) / 2;
  }
}
