import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/ui_state.dart';

@immutable
class VictoryOverlayState {
  final bool visible;
  final String? assetPath;

  const VictoryOverlayState({required this.visible, required this.assetPath});

  static const VictoryOverlayState hidden = VictoryOverlayState(
    visible: false,
    assetPath: null,
  );
}

class SudokuVictoryOverlayService {
  static const List<String> cartoonAssets = <String>[
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

  final Duration duration;
  final math.Random _random;
  final ValueNotifier<VictoryOverlayState> state;

  bool _wasPuzzleSolved = false;
  Timer? _timer;

  SudokuVictoryOverlayService({
    this.duration = const Duration(seconds: 10),
    math.Random? random,
  }) : _random = random ?? math.Random(),
       state = ValueNotifier<VictoryOverlayState>(VictoryOverlayState.hidden);

  void onUiStateChanged(UiState uiState) {
    if (uiState.puzzleSolved && !_wasPuzzleSolved) {
      _start();
    } else if (!uiState.puzzleSolved && state.value.visible) {
      _hide();
    }
    _wasPuzzleSolved = uiState.puzzleSolved;
  }

  void dispose() {
    _timer?.cancel();
    state.dispose();
  }

  void _start() {
    _timer?.cancel();
    final asset = cartoonAssets[_random.nextInt(cartoonAssets.length)];
    state.value = VictoryOverlayState(visible: true, assetPath: asset);
    _timer = Timer(duration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    state.value = VictoryOverlayState.hidden;
  }
}
