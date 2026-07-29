import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';

enum PremiumCelebrationStyle { foil, autumnLeaves, stars, confetti }

@immutable
class VictoryOverlayState {
  final bool visible;
  final String? assetPath;
  final PremiumCelebrationStyle? premiumCelebrationStyle;

  const VictoryOverlayState({
    required this.visible,
    required this.assetPath,
    required this.premiumCelebrationStyle,
  });

  static const VictoryOverlayState hidden = VictoryOverlayState(
    visible: false,
    assetPath: null,
    premiumCelebrationStyle: null,
  );
}

class SudokuVictoryOverlayService {
  static const List<PremiumCelebrationStyle> themedPremiumCelebrationStyles =
      <PremiumCelebrationStyle>[
        PremiumCelebrationStyle.foil,
        PremiumCelebrationStyle.autumnLeaves,
        PremiumCelebrationStyle.stars,
        PremiumCelebrationStyle.confetti,
      ];
  static List<String> get animalCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('animals');
  static List<String> get instrumentCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('instruments');
  static List<String> get oldOperaCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('old_opera');
  static List<String> get butterflyCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('butterflies');
  static List<String> get shellCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('shells');
  static List<String> get numberCelebrationAssets =>
      BundledThemeRepository.celebrationImagePathsForTheme('numbers');

  final Duration duration;
  final math.Random _random;
  final ValueNotifier<VictoryOverlayState> state;

  bool _wasPuzzleSolved = false;
  Timer? _timer;

  SudokuVictoryOverlayService({
    this.duration = const Duration(seconds: 8),
    math.Random? random,
  }) : _random = random ?? math.Random(),
       state = ValueNotifier<VictoryOverlayState>(VictoryOverlayState.hidden);

  void onUiStateChanged(UiState uiState) {
    if (uiState.puzzleSolved && !_wasPuzzleSolved) {
      _start(uiState.contentMode, uiState.premiumActive);
    } else if (!uiState.puzzleSolved && state.value.visible) {
      _hide();
    }
    _wasPuzzleSolved = uiState.puzzleSolved;
  }

  void dispose() {
    _timer?.cancel();
    state.dispose();
  }

  void _start(String contentMode, bool premiumActive) {
    _timer?.cancel();
    final normalizedMode = contentMode.trim().toLowerCase();
    final themeAssets = BundledThemeRepository.celebrationImagePathsForTheme(
      normalizedMode,
    );
    final assets = themeAssets.isEmpty ? numberCelebrationAssets : themeAssets;
    if (assets.isEmpty) {
      state.value = VictoryOverlayState.hidden;
      return;
    }
    final asset = assets[_random.nextInt(assets.length)];
    final premiumCelebrationStyle = premiumActive && normalizedMode != 'numbers'
        ? themedPremiumCelebrationStyles[_random.nextInt(
            themedPremiumCelebrationStyles.length,
          )]
        : null;
    state.value = VictoryOverlayState(
      visible: true,
      assetPath: asset,
      premiumCelebrationStyle: premiumCelebrationStyle,
    );
    _timer = Timer(duration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    state.value = VictoryOverlayState.hidden;
  }
}
