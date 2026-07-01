import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/ui_state.dart';

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
  static const List<String> animalCelebrationAssets = <String>[
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
  static const List<String> instrumentCelebrationAssets = <String>[
    'assets/images/music/piano.png',
    'assets/images/music/banjo.png',
    'assets/images/music/violin.png',
    'assets/images/music/trumpet.png',
    'assets/images/music/horn.png',
    'assets/images/music/drum.png',
    'assets/images/music/saxaphone.png',
    'assets/images/music/tambourine.png',
    'assets/images/music/ukelele.png',
  ];
  static const List<String> oldOperaCelebrationAssets = <String>[
    'assets/images/opera/bass.png',
    'assets/images/opera/baritone.png',
    'assets/images/opera/tenor.png',
    'assets/images/opera/mezzo_soprano.png',
    'assets/images/opera/soprano.png',
    'assets/images/opera/royal_court_singer.png',
    'assets/images/opera/modern_opera.png',
    'assets/images/opera/masked_phantom_style.png',
    'assets/images/opera/opera_diva_comic.png',
  ];
  static const List<String> butterflyCelebrationAssets = <String>[
    'assets/images/butterflies/1_monarch.png',
    'assets/images/butterflies/2_swallowtail.png',
    'assets/images/butterflies/3_blue_morpho.png',
    'assets/images/butterflies/4_glasswing.png',
    'assets/images/butterflies/5_peacock.png',
    'assets/images/butterflies/6_zebra_longwing.png',
    'assets/images/butterflies/7_sulphur.png',
    'assets/images/butterflies/8_leaf.png',
    'assets/images/butterflies/9_metalmark.png',
  ];
  static const List<String> shellCelebrationAssets = <String>[
    'assets/images/shells/1_cowrie.png',
    'assets/images/shells/2_scallop.png',
    'assets/images/shells/3_murex.png',
    'assets/images/shells/4_nautilus.png',
    'assets/images/shells/5_cone.png',
    'assets/images/shells/6_abalone.png',
    'assets/images/shells/7_turban.png',
    'assets/images/shells/8_moon_snail.png',
    'assets/images/shells/9_cockle.png',
  ];
  static const List<String> numberCelebrationAssets = <String>[
    ...animalCelebrationAssets,
    ...instrumentCelebrationAssets,
    ...butterflyCelebrationAssets,
    ...shellCelebrationAssets,
    ...oldOperaCelebrationAssets,
  ];

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
    final assets = switch (normalizedMode) {
      'animals' => animalCelebrationAssets,
      'instruments' => instrumentCelebrationAssets,
      'butterflies' => butterflyCelebrationAssets,
      'shells' => shellCelebrationAssets,
      'old_opera' => oldOperaCelebrationAssets,
      _ => numberCelebrationAssets,
    };
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
