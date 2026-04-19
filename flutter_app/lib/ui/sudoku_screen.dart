import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/sudoku_screen_flow_actions.dart';
import 'package:flutter_app/ui/services/sudoku_screen_service_registry.dart';
import 'package:flutter_app/ui/services/sudoku_start_instruction_overlay_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/help_dialog.dart';
import 'package:flutter_app/ui/widgets/sudoku_game_content_builder.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/sudoku_version_app_bar.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({
    super.key,
    required this.controller,
    this.animalAssetService = const AnimalAssetService(),
  });
  final SudokuController controller;
  final AnimalAssetService animalAssetService;
  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final Map<String, Map<int, ui.Image>> _animalImages = {};
  final Map<String, Map<int, Map<int, ui.Image>>> _noteImages = {};
  final _flowActions = const SudokuScreenFlowActions();
  final _startInstructionOverlayService =
      SudokuStartInstructionOverlayService();
  late final SudokuScreenServiceRegistry _services;
  Future<void>? _animalLoad;
  final GlobalKey _overlayStackKey = GlobalKey();
  final GlobalKey _tilesPanelKey = GlobalKey();
  final GlobalKey _bottomControlsKey = GlobalKey();
  bool _debugToolsEnabled = false;
  bool _audioEnabled = true;
  @override
  void initState() {
    super.initState();
    _services = SudokuScreenServiceRegistry(
      controller: widget.controller,
      onControllerChanged: _onControllerChanged,
      onVictoryOverlayChanged: () {
        _services.onVictoryOverlayChanged(
          overlayStackKey: _overlayStackKey,
          tilesPanelKey: _tilesPanelKey,
          bottomControlsKey: _bottomControlsKey,
          isMounted: () => mounted,
        );
      },
    );
    _ensureAnimalAssetsRequested(widget.controller.state.contentMode);
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
    final controller = widget.controller;
    final state = controller.state;
    _ensureAnimalAssetsRequested(state.contentMode);
    _services.onControllerChanged(
      context: context,
      state: state,
      isMounted: () => mounted,
      showCorrectionPrompt: () async {
        await _services.showCorrectionPrompt(
          context: context,
          isMounted: () => mounted,
          onConfirmCorrection: controller.onConfirmCorrection,
          onCorrectionConfirmed:
              _services.candidatePanelCoordinator.onCorrectionConfirmed,
          onDismissCorrectionPrompt: controller.onDismissCorrectionPrompt,
          currentState: () => controller.state,
        );
      },
    );
    _startInstructionOverlayService.onStateChanged(
      context: context,
      state: state,
      isMounted: () => mounted,
    );
  }

  void _ensureAnimalAssetsRequested(String contentMode) {
    if (contentMode == 'numbers' || _animalLoad != null) {
      return;
    }
    _animalLoad = _loadAnimalImages();
  }

  Future<void> _loadAnimalImages() async {
    try {
      final bundle = await widget.animalAssetService.load();
      _animalImages
        ..clear()
        ..addAll(bundle.animalImages);
      _noteImages
        ..clear()
        ..addAll(bundle.noteImages);
      if (mounted) {
        setState(() {});
      }
    } on Exception catch (error) {
      AppDebug.log('Failed to load visual assets: $error');
      _animalLoad = null;
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
        final controller = widget.controller;
        final state = controller.state;
        final assetVariant = switch (state.contentMode) {
          'animals' => state.animalStyle,
          'instruments' => 'instruments',
          _ => null,
        };
        final viewModel = SudokuScreenViewModel.from(
          state: state,
          coordinator: _services.candidatePanelCoordinator,
          selectionService: _services.candidateSelectionService,
          debugToolsEnabled: _debugToolsEnabled,
        );
        final style = styleForName(state.styleName);
        return Scaffold(
          appBar: SudokuVersionAppBar(
            onNewGamePressed: _onNewGamePressed,
            onVersionTapped: _onVersionTapped,
            onVersionLongPressed:
                _services.interactionController.onVersionLongPressed,
          ),
          drawer: SudokuDrawer(
            state: state,
            onAnimalStyleChanged: controller.onAnimalStyleChanged,
            onStyleChanged: controller.onStyleChanged,
            audioEnabled: _audioEnabled,
            onAudioEnabledChanged: _onAudioEnabledChanged,
            onLoadCorrectionScenario: () {
              Navigator.of(context).maybePop();
              controller.onLoadCorrectionScenario();
            },
            onLoadExhaustedCorrectionScenario: () {
              Navigator.of(context).maybePop();
              controller.onLoadExhaustedCorrectionScenario();
            },
            showDebugTools: viewModel.showDebugTools,
          ),
          body: SudokuGameContentBuilder(
            victoryStateListenable: _services.victoryOverlayService.state,
            victoryCenterYListenable: _services.victoryPositionService.centerY,
            state: state,
            style: style,
            animalImages: assetVariant == null
                ? const {}
                : (_animalImages[assetVariant] ?? const {}),
            noteImagesBySize: assetVariant == null
                ? const {}
                : (_noteImages[assetVariant] ?? const {}),
            devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
            viewModel: viewModel,
            overlayStackKey: _overlayStackKey,
            tilesPanelKey: _tilesPanelKey,
            bottomControlsKey: _bottomControlsKey,
            onDigitSelected:
                _services.interactionController.onCandidateDigitSelected,
            onDigitLongPressed: state.notesMode
                ? _services.interactionController.onCandidateDigitLongPressed
                : null,
            onTapCell: (coord) async {
              final state = widget.controller.state;
              await _services.interactionController.onCellTapped(
                state: state,
                coord: coord,
                animalLoad: _animalLoad,
              );
            },
            onLongPressCell: (globalPosition, coord) {
              _services.showCellTooltip(
                context: context,
                state: controller.state,
                coord: coord,
                globalPosition: globalPosition,
              );
            },
            onProgressPressed: () {
              unawaited(
                _flowActions.showProgressSheet(
                  context: context,
                  completedPuzzles: widget.controller.completedPuzzles,
                ),
              );
            },
            onHelpPressed: () => showSudokuHelpDialog(context),
            onContentModeChanged: controller.onContentModeChanged,
            onConfigurationLockTapped: () {
              unawaited(
                _flowActions.showLockedSettingsSheet(
                  context: context,
                  controller: controller,
                ),
              );
            },
            onConfigurationLockDoubleTapped: () {
              unawaited(
                _flowActions.requestUnlockByStartingNewGame(
                  context: context,
                  isMounted: () => mounted,
                  controller: controller,
                ),
              );
            },
            onPuzzleModeChanged: (mode) {
              unawaited(
                _flowActions.requestPuzzleModeChange(
                  context: context,
                  isMounted: () => mounted,
                  controller: widget.controller,
                  mode: mode,
                ),
              );
            },
            onSetDifficulty: (difficulty) {
              unawaited(
                _flowActions.requestDifficultyChange(
                  context: context,
                  isMounted: () => mounted,
                  controller: widget.controller,
                  difficulty: difficulty,
                ),
              );
            },
            onStyleChanged: controller.onStyleChanged,
            onUndo: controller.onUndo,
            onToggleNotesMode: controller.onToggleNotesMode,
            onClear: controller.onClearPressed,
            onCheckOrSolution: () => _services.interactionController
                .onCheckOrSolutionPressed(controller.state),
          ),
        );
      },
    );
  }

  void _onNewGamePressed() {
    unawaited(
      _flowActions.requestNewGame(
        context: context,
        isMounted: () => mounted,
        controller: widget.controller,
      ),
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

  void _onAudioEnabledChanged(bool enabled) {
    if (_audioEnabled == enabled) {
      return;
    }
    setState(() {
      _audioEnabled = enabled;
    });
    _services.onAudioEnabledChanged(enabled);
  }
}
