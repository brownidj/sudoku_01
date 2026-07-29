import 'package:flutter_app/ui/animal_cache_catalog.dart';

class BundledThemeAssets {
  const BundledThemeAssets._();

  static String animalName(int digit) =>
      nameAt(digit, AnimalCacheCatalog.animalNames, fallback: 'ape');

  static String instrumentName(int digit) =>
      nameAt(digit, AnimalCacheCatalog.instrumentNames, fallback: 'piano');

  static String operaName(int digit) =>
      nameAt(digit, AnimalCacheCatalog.operaNames, fallback: 'bass');

  static String butterflyName(int digit) =>
      nameAt(digit, AnimalCacheCatalog.butterflyNames, fallback: 'monarch');

  static String shellName(int digit) =>
      nameAt(digit, AnimalCacheCatalog.shellNames, fallback: 'cowrie');

  static String animalImagePath(int digit, {required String variant}) {
    final name = animalName(digit);
    if (variant == 'cute') {
      return 'assets/images/animals/${digit}_cartoon_${name}_s.png';
    }
    return 'assets/images/animals/${digit}_$name.png';
  }

  static String animalNoteImagePath(int digit, {required String variant}) {
    final name = animalName(digit);
    final prefix = variant == 'cute' ? 'cartoon_' : '';
    return 'assets/images/animals/${digit}_$prefix${name}_notes.png';
  }

  static String animalCelebrationImagePath(int digit) {
    const fileNames = <int, String>{
      1: '1_cartoon_ape.png',
      2: '2_cartoon_buffalo.png',
      3: '3_cartoon_camel.png',
      4: '4_cartoon_dolphin.png',
      5: '5_cartoon_elephant.png',
      6: '6_cartoon_frog.png',
      7: '7_cartoon_giraffe.png',
      8: '8_cartoon_hippo.png',
      9: '9_cartoon_iguana.png',
    };
    return 'assets/images/animals_chatGpT/${fileNames[digit] ?? fileNames[1]}';
  }

  static String instrumentImagePath(int digit) =>
      'assets/images/music/${nameAt(digit, AnimalCacheCatalog.instrumentFileNames, fallback: 'piano')}.png';

  static String operaImagePath(int digit) =>
      'assets/images/opera/${nameAt(digit, AnimalCacheCatalog.operaFileNames, fallback: 'bass')}.png';

  static String butterflyImagePath(int digit) =>
      'assets/images/butterflies/${nameAt(digit, AnimalCacheCatalog.butterflyFileNames, fallback: '1_monarch')}.png';

  static String shellImagePath(int digit) =>
      'assets/images/shells/${nameAt(digit, AnimalCacheCatalog.shellFileNames, fallback: '1_cowrie')}.png';

  static String nameAt(
    int digit,
    List<String> names, {
    required String fallback,
  }) {
    if (digit < 1 || digit > names.length) {
      return fallback;
    }
    return names[digit - 1];
  }

  static String titleCase(String raw) {
    return raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

const Map<int, String> bundledAnimalAudioAssets = {
  1: 'audio/animals/apes.mp3',
  2: 'audio/animals/buffalo.mp3',
  3: 'audio/animals/cheetah.mp3',
  4: 'audio/animals/dolphin.mp3',
  5: 'audio/animals/elephant.mp3',
  6: 'audio/animals/frog.mp3',
  7: 'audio/animals/giraffe.mp3',
  8: 'audio/animals/hippos.mp3',
  9: 'audio/animals/iguana.mp3',
};

const Map<int, String> bundledAnimalCelebrationAudioAssets = {
  1: 'audio/animals/apes.mp3',
  2: 'audio/animals/buffalo.mp3',
  3: 'audio/animals/camel.mp3',
  4: 'audio/animals/dolphin.mp3',
  5: 'audio/animals/elephant.mp3',
  6: 'audio/animals/frog.mp3',
  7: 'audio/animals/giraffe.mp3',
  8: 'audio/animals/hippos.mp3',
  9: 'audio/animals/iguana.mp3',
};

const Map<int, String> bundledInstrumentAudioAssets = {
  1: 'audio/music/piano.mp3',
  2: 'audio/music/banjo.mp3',
  3: 'audio/music/violin.mp3',
  4: 'audio/music/trumpet.mp3',
  5: 'audio/music/horn.mp3',
  6: 'audio/music/drum.mp3',
  7: 'audio/music/saxophone.mp3',
  8: 'audio/music/tambourine.mp3',
  9: 'audio/music/ukulele.mp3',
};

const Map<int, String> bundledOperaAudioAssets = {
  1: 'audio/opera/bass.mp3',
  2: 'audio/opera/baritone.mp3',
  3: 'audio/opera/tenor.mp3',
  4: 'audio/opera/mezzo_soprano.mp3',
  5: 'audio/opera/soprano.mp3',
  6: 'audio/opera/royal_court_singer.mp3',
  7: 'audio/opera/modern_opera.mp3',
  8: 'audio/opera/masked_phantom_style.mp3',
  9: 'audio/opera/opera_diva_comic.mp3',
};

const Map<int, String> bundledButterflyAudioAssets = {
  1: 'audio/butterflies/1_monarch.wav',
  2: 'audio/butterflies/2_swallowtail.wav',
  3: 'audio/butterflies/3_blue_morpho.wav',
  4: 'audio/butterflies/4_glasswing.wav',
  5: 'audio/butterflies/5_peacock.wav',
  6: 'audio/butterflies/6_zebra_longwing.wav',
  7: 'audio/butterflies/7_sulphur.wav',
  8: 'audio/butterflies/8_leaf.wav',
  9: 'audio/butterflies/9_metalmark.wav',
};

const Map<int, String> bundledShellAudioAssets = {
  1: 'audio/shells/1_cowrie.mp3',
  2: 'audio/shells/2_scallop.mp3',
  3: 'audio/shells/3_murex.mp3',
  4: 'audio/shells/4_nautilus.mp3',
  5: 'audio/shells/5_cone.mp3',
  6: 'audio/shells/6_abalone.mp3',
  7: 'audio/shells/7_turban.mp3',
  8: 'audio/shells/8_moon_snail.mp3',
  9: 'audio/shells/9_cockle.mp3',
};
