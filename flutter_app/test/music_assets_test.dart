import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _musicImageAssets = <String>[
  'assets/images/music/banjo.png',
  'assets/images/music/drum.png',
  'assets/images/music/horn.png',
  'assets/images/music/maracas.png',
  'assets/images/music/piano.png',
  'assets/images/music/saxaphone.png',
  'assets/images/music/tambourine.png',
  'assets/images/music/trumpet.png',
  'assets/images/music/ukelele.png',
  'assets/images/music/violin.png',
];

const _musicAudioAssets = <String>[
  'assets/audio/music/accordion.mp3',
  'assets/audio/music/banjo.mp3',
  'assets/audio/music/drum.mp3',
  'assets/audio/music/horn.mp3',
  'assets/audio/music/maracas.mp3',
  'assets/audio/music/piano.mp3',
  'assets/audio/music/saxophone.mp3',
  'assets/audio/music/tambourine.mp3',
  'assets/audio/music/trumpet.mp3',
  'assets/audio/music/ukulele.mp3',
  'assets/audio/music/violin.mp3',
];

const _animalAudioAssets = <String>[
  'assets/audio/animals/apes.mp3',
  'assets/audio/animals/buffalo.mp3',
  'assets/audio/animals/camel.mp3',
  'assets/audio/animals/cheetah.mp3',
  'assets/audio/animals/dolphin.mp3',
  'assets/audio/animals/elephant.mp3',
  'assets/audio/animals/frog.mp3',
  'assets/audio/animals/giraffe.mp3',
  'assets/audio/animals/hippos.mp3',
  'assets/audio/animals/iguana.mp3',
];

const _operaImageAssets = <String>[
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

const _operaAudioAssets = <String>[
  'assets/audio/opera/bass.mp3',
  'assets/audio/opera/baritone.mp3',
  'assets/audio/opera/masked_phantom_style.mp3',
  'assets/audio/opera/mezzo_soprano.mp3',
  'assets/audio/opera/modern_opera.mp3',
  'assets/audio/opera/opera_diva_comic.mp3',
  'assets/audio/opera/royal_court_singer.mp3',
  'assets/audio/opera/tenor.mp3',
  'assets/audio/opera/soprano.mp3',
];

Future<void> _expectAssetsLoadable(List<String> assets) async {
  for (final asset in assets) {
    final data = await rootBundle.load(asset);
    expect(data.lengthInBytes, greaterThan(0), reason: 'Empty asset: $asset');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bundles instrument image assets', (tester) async {
    await _expectAssetsLoadable(_musicImageAssets);
  });

  testWidgets('bundles instrument audio assets', (tester) async {
    await _expectAssetsLoadable(_musicAudioAssets);
  });

  testWidgets('bundles animal audio assets', (tester) async {
    await _expectAssetsLoadable(_animalAudioAssets);
  });

  testWidgets('bundles old opera image assets', (tester) async {
    await _expectAssetsLoadable(_operaImageAssets);
  });

  testWidgets('bundles old opera audio assets', (tester) async {
    await _expectAssetsLoadable(_operaAudioAssets);
  });
}
