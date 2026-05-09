import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/app_debug.dart';

class SudokuTilePreviewAudioService {
  final AudioPlayer _player;
  final Duration _maxClipDuration;

  bool _enabled = true;
  double _volume = 0.5;
  Timer? _autoStopTimer;

  SudokuTilePreviewAudioService({
    AudioPlayer? player,
    Duration maxClipDuration = const Duration(seconds: 3),
  }) : _player = player ?? AudioPlayer(),
       _maxClipDuration = maxClipDuration {
    unawaited(
      _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      ),
    );
    unawaited(_player.setVolume(_volume));
  }

  void setEnabled(bool enabled) {
    if (_enabled == enabled) {
      return;
    }
    _enabled = enabled;
    if (!enabled) {
      unawaited(_stop());
    }
  }

  bool playForTile({required String contentMode, required int digit}) {
    if (!_enabled) {
      return false;
    }
    final asset = audioAssetForTile(contentMode: contentMode, digit: digit);
    if (asset == null) {
      return false;
    }
    unawaited(_play(asset));
    return true;
  }

  void setVolume(double volume) {
    final next = volume.clamp(0.0, 1.0);
    if (_volume == next) {
      return;
    }
    _volume = next;
    unawaited(_player.setVolume(_volume));
  }

  Duration get maxClipDuration => _maxClipDuration;

  static String? audioAssetForTile({
    required String contentMode,
    required int digit,
  }) {
    final normalizedMode = contentMode.trim().toLowerCase();
    if (digit < 1 || digit > 9) {
      return null;
    }
    const animalAssets = <int, String>{
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
    const instrumentAssets = <int, String>{
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
    const operaAssets = <int, String>{
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
    const butterflyAssets = <int, String>{
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
    return switch (normalizedMode) {
      'animals' => animalAssets[digit],
      'instruments' => instrumentAssets[digit],
      'butterflies' => butterflyAssets[digit],
      'old_opera' => operaAssets[digit],
      _ => null,
    };
  }

  void dispose() {
    unawaited(_disposeInternal());
  }

  Future<void> _play(String asset) async {
    try {
      _autoStopTimer?.cancel();
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!await _playAssetWithFallback(asset)) {
        throw StateError('No playable source for asset $asset');
      }
      _autoStopTimer = Timer(_maxClipDuration, () {
        unawaited(_stop());
      });
    } on Exception catch (error) {
      AppDebug.log('Failed to play tile preview audio: $error');
    }
  }

  Future<bool> _playAssetWithFallback(String asset) async {
    try {
      await _player.play(AssetSource(asset));
      return true;
    } catch (error) {
      AppDebug.log('Primary tile audio asset failed ($asset): $error');
    }
    try {
      await _player.play(AssetSource('assets/$asset'));
      return true;
    } catch (error) {
      AppDebug.log('Fallback tile audio asset failed (assets/$asset): $error');
      return false;
    }
  }

  Future<void> _stop() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    try {
      await _player.stop();
    } on Exception catch (error) {
      AppDebug.log('Failed to stop tile preview audio: $error');
    }
  }

  Future<void> _disposeInternal() async {
    await _stop();
    try {
      await _player.dispose();
    } on Exception catch (error) {
      AppDebug.log('Failed to dispose tile preview audio player: $error');
    }
  }
}
