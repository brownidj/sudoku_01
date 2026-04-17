import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/services/sudoku_victory_audio_service.dart';

void main() {
  test('maps victory mascot assets to expected audio clips', () {
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/1_cartoon_ape.png',
      ),
      'audio/apes.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/2_cartoon_buffalo.png',
      ),
      'audio/buffalo.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/3_cartoon_camel.png',
      ),
      'audio/cheetah.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/4_cartoon_dolphin.png',
      ),
      'audio/dolphin.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/5_cartoon_elephant.png',
      ),
      'audio/elephant.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/6_cartoon_frog.png',
      ),
      'audio/frog.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/7_cartoon_giraffe.png',
      ),
      'audio/giraffe.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/8_cartoon_hippo.png',
      ),
      'audio/hippos.mp3',
    );
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/9_cartoon_iguana.png',
      ),
      'audio/iguana.mp3',
    );
  });

  test('returns null for unknown mascot asset path', () {
    expect(SudokuVictoryAudioService.audioAssetForVictoryMascot(null), isNull);
    expect(
      SudokuVictoryAudioService.audioAssetForVictoryMascot(
        'assets/images/animals_chatGpT/unknown.png',
      ),
      isNull,
    );
  });
}
