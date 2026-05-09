const List<String> backgroundButterflyTracks = <String>[
  'audio/background/butterflies/blue_morpho_lullaby_2.mp3',
  'audio/background/butterflies/blue_morpho_lullaby.mp3',
  'audio/background/butterflies/drifting_leaf_waltz_2.mp3',
  'audio/background/butterflies/drifting_leaf_waltz.mp3',
  'audio/background/butterflies/flamboyant_glide_2.mp3',
  'audio/background/butterflies/flamboyant_glide.mp3',
  'audio/background/butterflies/glasswing_glide_2.mp3',
  'audio/background/butterflies/glasswing_glide.mp3',
  'audio/background/butterflies/metamorphic_rave_2.mp3',
  'audio/background/butterflies/metamorphic_rave.mp3',
  'audio/background/butterflies/monarchs_march_2.mp3',
  'audio/background/butterflies/monarchs_march.mp3',
  'audio/background/butterflies/savannah_flutter_2.mp3',
  'audio/background/butterflies/savannah_flutter.mp3',
  'audio/background/butterflies/sulphur_shuffle_2.mp3',
  'audio/background/butterflies/sulphur_shuffle.mp3',
  'audio/background/butterflies/swallowtail_swoop_2.mp3',
  'audio/background/butterflies/swallowtail_swoop.mp3',
];

const List<String> backgroundOperaTracks = <String>[
  'audio/background/opera/il_mio_segreto_2.mp3',
  'audio/background/opera/il_mio_segreto.mp3',
  'audio/background/opera/o_mio_amore_2.mp3',
  'audio/background/opera/o_mio_amore.mp3',
];

List<String> backgroundTracksForContentMode(String contentMode) {
  return switch (contentMode) {
    'butterflies' => backgroundButterflyTracks,
    'old_opera' => backgroundOperaTracks,
    _ => const <String>[],
  };
}

bool shouldAttemptBackgroundMusicPlayback({
  required bool audioEnabled,
  required bool backgroundMusicEnabled,
  required bool sessionInProgress,
  required bool themeSupportsBackgroundMusic,
  required bool hasSuspensions,
}) {
  return audioEnabled &&
      backgroundMusicEnabled &&
      sessionInProgress &&
      themeSupportsBackgroundMusic &&
      !hasSuspensions;
}
