import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/app/monetization_config.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/application/solver.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/sudoku_screen_flow_actions.dart';
import 'package:flutter_app/ui/services/sudoku_screen_service_registry.dart';
import 'package:flutter_app/ui/services/sudoku_start_instruction_overlay_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_audio_service.dart';
import 'package:flutter_app/ui/sudoku_screen_view_model.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/help_dialog.dart';
import 'package:flutter_app/ui/widgets/sudoku_game_content_builder.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/sudoku_version_app_bar.dart';
part 'sudoku_screen_handlers.dart';
part 'sudoku_screen_builders.dart';
part 'sudoku_screen_screenshot_mode.dart';
part 'sudoku_screen_screenshot_helpers.dart';

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
  final _premiumPolicy = const PremiumPolicyService();
  final _startInstructionOverlayService =
      SudokuStartInstructionOverlayService();
  late final SudokuScreenServiceRegistry _services;
  Future<void>? _animalLoad;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _overlayStackKey = GlobalKey();
  final GlobalKey _tilesPanelKey = GlobalKey();
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _bottomControlsKey = GlobalKey();
  bool _debugToolsEnabled = false;
  bool _audioEnabled = false;
  bool _screenshotSceneApplied = false;
  bool _backgroundMusicEnabled = false;
  double _audioVolume = 0.4;

  void _updateScreenState(VoidCallback updates) {
    if (!mounted) {
      return;
    }
    setState(updates);
  }

  @override
  void initState() {
    super.initState();
    _services = SudokuScreenServiceRegistry(
      controller: widget.controller,
      onControllerChanged: _onControllerChanged,
      onVictoryOverlayChanged: () {
        _services.onVictoryOverlayChanged(
          overlayStackKey: _overlayStackKey,
          boardKey: _boardKey,
          bottomControlsKey: _bottomControlsKey,
          isMounted: () => mounted,
        );
      },
    );
    _ensureAnimalAssetsRequested(widget.controller.state.contentMode);
    _loadAudioPreferences();
    if (ScreenshotMode.enabled && !ScreenshotMode.isHome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_applyScreenshotSceneIfNeeded());
      });
    }
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
          'butterflies' => 'butterflies',
          'shells' => 'shells',
          'old_opera' => 'old_opera',
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
          key: _scaffoldKey,
          appBar: SudokuVersionAppBar(
            onVersionTapped: _onVersionTapped,
            audioEnabled: _audioEnabled,
            showMusicControls: _premiumPolicy.isBackgroundMusicThemeMode(
              state.contentMode,
            ),
            backgroundMusicEnabled: _backgroundMusicEnabled,
            onMusicControlSingleTap: _onMusicControlSingleTap,
            onMusicControlDoubleTap: _onMusicControlDoubleTap,
            onPreviousTrackTapped: _onPreviousTrackTapped,
            onNextTrackTapped: _onNextTrackTapped,
          ),
          drawer: _buildDrawer(
            context: context,
            controller: controller,
            viewModel: viewModel,
          ),
          body: _buildGameContent(
            context: context,
            controller: controller,
            state: state,
            style: style,
            assetVariant: assetVariant,
            viewModel: viewModel,
          ),
        );
      },
    );
  }
}
