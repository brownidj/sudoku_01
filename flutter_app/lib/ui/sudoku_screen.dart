import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_content_asset_selector.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/sudoku_new_game_confirmation_service.dart';
import 'package:flutter_app/ui/services/sudoku_screen_service_registry.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/help_dialog.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/sudoku_game_content.dart';
import 'package:flutter_app/ui/widgets/sudoku_version_app_bar.dart';

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
  late final SudokuScreenServiceRegistry _services;
  final SudokuNewGameConfirmationService _newGameConfirmationService =
      const SudokuNewGameConfirmationService();
  Future<void>? _animalLoad;
  final GlobalKey _overlayStackKey = GlobalKey();
  final GlobalKey _tilesPanelKey = GlobalKey();
  final GlobalKey _bottomControlsKey = GlobalKey();
  bool _debugToolsEnabled = false;
  bool _audioEnabled = true;
  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
    _services = SudokuScreenServiceRegistry(
      controller: widget.controller,
      onControllerChanged: _onControllerChanged,
      onVictoryOverlayChanged: _onVictoryOverlayChanged,
    );
  }

  @override
  void didUpdateWidget(covariant SudokuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _services.updateController(widget.controller);
  }

  @override
  void dispose() {
    _services.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final state = widget.controller.state;
    _services.onControllerChanged(
      context: context,
      state: state,
      isMounted: () => mounted,
      showCorrectionPrompt: _showCorrectionPrompt,
    );
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
      animation: Listenable.merge([
        widget.controller,
        _services.candidateSelectionService,
      ]),
      builder: (context, _) {
        final state = widget.controller.state;
        final viewModel = SudokuScreenViewModel.from(
          state: state,
          coordinator: _services.candidatePanelCoordinator,
          selectionService: _services.candidateSelectionService,
          debugToolsEnabled: _debugToolsEnabled,
        );
        final style = styleForName(state.styleName);
        return Scaffold(
          appBar: SudokuVersionAppBar(
            onVersionTapped: _onVersionTapped,
            onVersionLongPressed: _onVersionLongPressed,
          ),
          drawer: SudokuDrawer(
            state: state,
            onAnimalStyleChanged: widget.controller.onAnimalStyleChanged,
            onStyleChanged: widget.controller.onStyleChanged,
            audioEnabled: _audioEnabled,
            onAudioEnabledChanged: _onAudioEnabledChanged,
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
            showDebugTools: viewModel.showDebugTools,
          ),
          body: ValueListenableBuilder<VictoryOverlayState>(
            valueListenable: _services.victoryOverlayService.state,
            builder: (context, victoryState, _) {
              return ValueListenableBuilder<double?>(
                valueListenable: _services.victoryPositionService.centerY,
                builder: (context, centerY, _) {
                  return SudokuGameContent(
                    state: state,
                    style: style,
                    animalImages: SudokuContentAssetSelector.imagesForState(
                      state,
                      imagesByVariant: _animalImages,
                    ),
                    noteImagesBySize: SudokuContentAssetSelector.notesForState(
                      state,
                      notesByVariant: _noteImages,
                    ),
                    devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                    candidateVisible: viewModel.candidateVisible,
                    candidateDigits: viewModel.candidateDigits,
                    selectedNotes: viewModel.selectedNotes,
                    onDigitSelected: _services
                        .interactionController
                        .onCandidateDigitSelected,
                    onDigitLongPressed: state.notesMode
                        ? _services
                              .interactionController
                              .onCandidateDigitLongPressed
                        : null,
                    onTapCell: _handleCellTap,
                    onLongPressCell: _handleCellLongPress,
                    showDebugNotification: viewModel.showDebugNotification,
                    overlayStackKey: _overlayStackKey,
                    tilesPanelKey: _tilesPanelKey,
                    bottomControlsKey: _bottomControlsKey,
                    onNewGame: _onNewGameRequested,
                    onContentModeChanged:
                        widget.controller.onContentModeChanged,
                    onConfigurationLockTapped: _onConfigurationLockTapped,
                    onPuzzleModeChanged: _onPuzzleModeRequested,
                    onSetDifficulty: _onDifficultyRequested,
                    onStyleChanged: widget.controller.onStyleChanged,
                    onUndo: widget.controller.onUndo,
                    onToggleNotesMode: widget.controller.onToggleNotesMode,
                    onClear: widget.controller.onClearPressed,
                    onCheckOrSolution: () => _services.interactionController
                        .onCheckOrSolutionPressed(widget.controller.state),
                    showVictoryOverlay: victoryState.visible,
                    victoryAssetPath: victoryState.assetPath,
                    victoryImageCenterY: centerY,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleCellLongPress(Offset globalPosition, Coord coord) {
    _services.showCellTooltip(
      context: context,
      state: widget.controller.state,
      coord: coord,
      globalPosition: globalPosition,
    );
  }

  Future<void> _handleCellTap(Coord coord) async {
    final state = widget.controller.state;
    await _services.interactionController.onCellTapped(
      state: state,
      coord: coord,
      animalLoad: _animalLoad,
    );
  }

  Future<void> _showCorrectionPrompt() async {
    await _services.showCorrectionPrompt(
      context: context,
      isMounted: () => mounted,
      onConfirmCorrection: widget.controller.onConfirmCorrection,
      onCorrectionConfirmed:
          _services.candidatePanelCoordinator.onCorrectionConfirmed,
      onDismissCorrectionPrompt: widget.controller.onDismissCorrectionPrompt,
      currentState: () => widget.controller.state,
    );
  }

  void _onVersionTapped() {
    final result = _services.interactionController.onVersionTapped(
      appDebugEnabled: AppDebug.enabled,
    );
    if (result.toggleDebugTools) {
      setState(() {
        _debugToolsEnabled = !_debugToolsEnabled;
      });
    }
  }

  void _onVersionLongPressed() {
    _services.interactionController.onVersionLongPressed();
  }

  void _onAudioEnabledChanged(bool enabled) {
    if (_audioEnabled == enabled) {
      return;
    }
    setState(() {
      _audioEnabled = enabled;
    });
    _services.onAudioEnabledChanged(enabled);
  }

  void _onVictoryOverlayChanged() {
    _services.onVictoryOverlayChanged(
      overlayStackKey: _overlayStackKey,
      tilesPanelKey: _tilesPanelKey,
      bottomControlsKey: _bottomControlsKey,
      isMounted: () => mounted,
    );
  }

  void _onConfigurationLockTapped() {
    final state = widget.controller.state;
    final difficultyLocked = !state.canChangeDifficulty;
    final puzzleModeLocked = !state.canChangePuzzleMode;
    final message = switch ((difficultyLocked, puzzleModeLocked)) {
      (true, true) =>
        'Difficulty and puzzle mode are locked for this board. Start a new game when you are ready to change them.',
      (true, false) =>
        'Difficulty is locked for this board. Start a new game when you are ready to change it.',
      (false, true) =>
        'Puzzle mode is locked for this board. Start a new game when you are ready to change it.',
      (false, false) =>
        'Some board settings are currently locked. Start a new game to change them.',
    };
    _showLockedFeatureSheet(title: 'Board Settings Locked', message: message);
  }

  Future<void> _showLockedFeatureSheet({
    required String title,
    required String message,
  }) {
    return showInfoSheet(context: context, title: title, message: message);
  }

  void _onPuzzleModeRequested(String mode) {
    final state = widget.controller.state;
    if (mode == state.puzzleMode) {
      return;
    }
    if (state.gameOver) {
      widget.controller.onConfirmPuzzleModeChanged(mode);
      return;
    }
    unawaited(
      _newGameConfirmationService.confirmAndRun(
        context: context,
        isMounted: () => mounted,
        title: 'Start New Game?',
        message:
            'Switch puzzle mode to ${mode.toUpperCase()} and start a fresh game?',
        onConfirm: () => widget.controller.onConfirmPuzzleModeChanged(mode),
      ),
    );
  }

  void _onNewGameRequested() {
    final state = widget.controller.state;
    final shouldRequireConfirmation =
        !state.gameOver &&
        (widget.controller.isCurrentGameResumed || state.canUndo);
    if (!shouldRequireConfirmation) {
      widget.controller.onNewGame();
      return;
    }
    unawaited(
      _newGameConfirmationService.confirmAndRun(
        context: context,
        isMounted: () => mounted,
        title: 'Start New Game?',
        message: 'Start a fresh game and reset this board?',
        onConfirm: widget.controller.onNewGame,
      ),
    );
  }

  void _onDifficultyRequested(String difficulty) {
    final state = widget.controller.state;
    if (difficulty == state.difficulty) {
      return;
    }
    if (state.gameOver) {
      widget.controller.onConfirmSetDifficulty(difficulty);
      return;
    }
    unawaited(
      _newGameConfirmationService.confirmAndRun(
        context: context,
        isMounted: () => mounted,
        title: 'Start New Game?',
        message:
            'Switch difficulty to ${difficulty.toUpperCase()} and start a fresh game?',
        onConfirm: () => widget.controller.onConfirmSetDifficulty(difficulty),
      ),
    );
  }
}
