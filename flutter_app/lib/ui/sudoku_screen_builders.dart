part of 'sudoku_screen.dart';

extension _SudokuScreenBuilders on _SudokuScreenState {
  Widget _buildDrawer({
    required BuildContext context,
    required SudokuController controller,
    required SudokuScreenViewModel viewModel,
  }) {
    return SudokuDrawer(
      state: controller.state,
      onAnimalStyleChanged: controller.onAnimalStyleChanged,
      onStyleChanged: controller.onStyleChanged,
      audioEnabled: _audioEnabled,
      onAudioEnabledChanged: _onAudioEnabledChanged,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      onBackgroundMusicEnabledChanged: _onBackgroundMusicEnabledChanged,
      audioVolume: _audioVolume,
      onAudioVolumeChanged: _onAudioVolumeChanged,
      onPremiumFeatureSelected: (feature) {
        Navigator.of(context).maybePop();
        unawaited(
          _flowActions.showPremiumFeatureLockedByKeySheet(
            context: context,
            featureKey: feature,
            onUnlockPremium: () => _flowActions.requestPremiumUnlock(
              context: context,
              controller: controller,
            ),
          ),
        );
      },
      onUnlockPremiumSelected: () {
        Navigator.of(context).maybePop();
        unawaited(
          _flowActions.showPremiumFeatureLockedSheet(
            context: context,
            featureLabel: 'Full Version Features',
            onUnlockPremium: () => _flowActions.requestPremiumUnlock(
              context: context,
              controller: controller,
            ),
          ),
        );
      },
      onRestorePurchasesSelected: () {
        Navigator.of(context).maybePop();
        unawaited(
          _flowActions.requestRestorePurchases(
            context: context,
            controller: controller,
          ),
        );
      },
      onLoadCorrectionScenario: () {
        Navigator.of(context).maybePop();
        controller.onLoadCorrectionScenario();
      },
      onLoadExhaustedCorrectionScenario: () {
        Navigator.of(context).maybePop();
        controller.onLoadExhaustedCorrectionScenario();
      },
      onResetEntitlementToFreeSelected: () {
        if (!MonetizationConfig.enableResetToFreeDebugAction) {
          return;
        }
        Navigator.of(context).maybePop();
        controller.onSetEntitlement(Entitlement.free);
      },
      selectedLanguageCode: controller.preferredLanguageCode,
      onLanguageChanged: (languageCode) {
        Navigator.of(context).maybePop();
        unawaited(controller.onPreferredLanguageChanged(languageCode));
      },
      onResetToSystemLanguage: () {
        Navigator.of(context).maybePop();
        unawaited(controller.onResetPreferredLanguageToSystem());
      },
      showDebugTools: viewModel.showDebugTools,
      showResetEntitlementToFree:
          MonetizationConfig.enableResetToFreeDebugAction,
    );
  }

  Widget _buildGameContent({
    required BuildContext context,
    required SudokuController controller,
    required UiState state,
    required BoardStyle style,
    required String? assetVariant,
    required SudokuScreenViewModel viewModel,
  }) {
    return SudokuGameContentBuilder(
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
      boardKey: _boardKey,
      bottomControlsKey: _bottomControlsKey,
      onDigitSelected: _services.interactionController.onCandidateDigitSelected,
      onDigitLongPressed: state.notesMode
          ? _services.interactionController.onCandidateDigitLongPressed
          : null,
      onTapCell: (coord) async {
        final currentState = widget.controller.state;
        await _services.interactionController.onCellTapped(
          state: currentState,
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
            showExtendedMetrics: state.premiumActive,
            completedPuzzles: widget.controller.completedPuzzles,
            daysPlayed: widget.controller.daysPlayed,
            streak: widget.controller.streak,
            currentGameElapsedSeconds: _currentGameElapsedSeconds(state),
            bestSolveTimeSecondsByDifficulty:
                widget.controller.bestSolveTimeSecondsByDifficulty,
            onResetProgressMetrics: widget.controller.resetProgressMetrics,
          ),
        );
      },
      onHelpPressed: () => showSudokuHelpDialog(context),
      onContentModeChanged: (mode) {
        unawaited(
          _flowActions.requestContentModeChange(
            context: context,
            controller: controller,
            contentMode: mode,
          ),
        );
      },
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
      onNewGamePressed: _onNewGamePressed,
    );
  }

  int? _currentGameElapsedSeconds(UiState state) {
    final startedAt = state.puzzleStartedAt;
    if (startedAt == null) {
      return null;
    }
    final end = state.puzzleFinishedAt ?? DateTime.now();
    final seconds = end.difference(startedAt).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }
}
