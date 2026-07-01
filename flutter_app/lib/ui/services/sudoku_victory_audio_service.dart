import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';

class SudokuVictoryAudioService {
  final AudioPlayer _player;
  final Duration _maxLoopDuration;

  String? _currentAudioAsset;
  bool _looping = false;
  bool _enabled = true;
  double _volume = 0.5;
  Timer? _autoStopTimer;

  SudokuVictoryAudioService({
    AudioPlayer? player,
    Duration maxLoopDuration = const Duration(seconds: 8),
  }) : _player = player ?? AudioPlayer(),
       _maxLoopDuration = maxLoopDuration {
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
      unawaited(_stopLoop());
    }
  }

  void onOverlayStateChanged(VictoryOverlayState overlayState) {
    if (!_enabled || !overlayState.visible) {
      unawaited(_stopLoop());
      return;
    }

    final audioAsset = audioAssetForVictoryMascot(overlayState.assetPath);
    if (audioAsset == null) {
      unawaited(_stopLoop());
      return;
    }

    if (_looping && _currentAudioAsset == audioAsset) {
      return;
    }
    unawaited(_playLoop(audioAsset));
  }

  void setVolume(double volume) {
    final next = volume.clamp(0.0, 1.0);
    if (_volume == next) {
      return;
    }
    _volume = next;
    unawaited(_player.setVolume(_volume));
  }

  void dispose() {
    unawaited(_disposeInternal());
  }

  static String? audioAssetForVictoryMascot(String? mascotAssetPath) {
    if (mascotAssetPath == null) {
      return null;
    }
    final lower = mascotAssetPath.toLowerCase().replaceAll('\\', '/');
    final fileName = lower.split('/').last;
    const explicitMap = <String, String>{
      '1_cartoon_ape.png': 'audio/animals/apes.mp3',
      '2_cartoon_buffalo.png': 'audio/animals/buffalo.mp3',
      '3_cartoon_camel.png': 'audio/animals/camel.mp3',
      '4_cartoon_dolphin.png': 'audio/animals/dolphin.mp3',
      '5_cartoon_elephant.png': 'audio/animals/elephant.mp3',
      '6_cartoon_frog.png': 'audio/animals/frog.mp3',
      '7_cartoon_giraffe.png': 'audio/animals/giraffe.mp3',
      '8_cartoon_hippo.png': 'audio/animals/hippos.mp3',
      '9_cartoon_iguana.png': 'audio/animals/iguana.mp3',
      'piano.png': 'audio/music/piano.mp3',
      'banjo.png': 'audio/music/banjo.mp3',
      'violin.png': 'audio/music/violin.mp3',
      'trumpet.png': 'audio/music/trumpet.mp3',
      'horn.png': 'audio/music/horn.mp3',
      'drum.png': 'audio/music/drum.mp3',
      'maracas.png': 'audio/music/maracas.mp3',
      'tambourine.png': 'audio/music/tambourine.mp3',
      'saxaphone.png': 'audio/music/saxophone.mp3',
      'saxophone.png': 'audio/music/saxophone.mp3',
      'ukelele.png': 'audio/music/ukulele.mp3',
      'ukulele.png': 'audio/music/ukulele.mp3',
      'bass.png': 'audio/opera/bass.mp3',
      'baritone.png': 'audio/opera/baritone.mp3',
      'tenor.png': 'audio/opera/tenor.mp3',
      'mezzo_soprano.png': 'audio/opera/mezzo_soprano.mp3',
      'soprano.png': 'audio/opera/soprano.mp3',
      'royal_court_singer.png': 'audio/opera/royal_court_singer.mp3',
      'modern_opera.png': 'audio/opera/modern_opera.mp3',
      'masked_phantom_style.png': 'audio/opera/masked_phantom_style.mp3',
      'opera_diva_comic.png': 'audio/opera/opera_diva_comic.mp3',
      '1_monarch.png': 'audio/butterflies/1_monarch.wav',
      '2_swallowtail.png': 'audio/butterflies/2_swallowtail.wav',
      '3_blue_morpho.png': 'audio/butterflies/3_blue_morpho.wav',
      '4_glasswing.png': 'audio/butterflies/4_glasswing.wav',
      '5_peacock.png': 'audio/butterflies/5_peacock.wav',
      '6_zebra_longwing.png': 'audio/butterflies/6_zebra_longwing.wav',
      '7_sulphur.png': 'audio/butterflies/7_sulphur.wav',
      '8_leaf.png': 'audio/butterflies/8_leaf.wav',
      '9_metalmark.png': 'audio/butterflies/9_metalmark.wav',
      '1_cowrie.png': 'audio/shells/1_cowrie.mp3',
      '2_scallop.png': 'audio/shells/2_scallop.mp3',
      '3_murex.png': 'audio/shells/3_murex.mp3',
      '4_nautilus.png': 'audio/shells/4_nautilus.mp3',
      '5_cone.png': 'audio/shells/5_cone.mp3',
      '6_abalone.png': 'audio/shells/6_abalone.mp3',
      '7_turban.png': 'audio/shells/7_turban.mp3',
      '8_moon_snail.png': 'audio/shells/8_moon_snail.mp3',
      '9_cockle.png': 'audio/shells/9_cockle.mp3',
    };
    return explicitMap[fileName];
  }

  Future<void> _playLoop(String audioAsset) async {
    try {
      _autoStopTimer?.cancel();
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      if (!await _playAssetWithFallback(audioAsset)) {
        throw StateError('No playable source for asset $audioAsset');
      }
      _currentAudioAsset = audioAsset;
      _looping = true;
      _autoStopTimer = Timer(_maxLoopDuration, () {
        unawaited(_stopLoop());
      });
    } catch (error) {
      AppDebug.log('Failed to play victory audio loop: $error');
      _currentAudioAsset = null;
      _looping = false;
    }
  }

  Future<bool> _playAssetWithFallback(String audioAsset) async {
    final normalized = audioAsset.startsWith('assets/')
        ? audioAsset.substring('assets/'.length)
        : audioAsset;
    for (final candidate in <String>{normalized, audioAsset}) {
      try {
        await _player.play(AssetSource(candidate));
        return true;
      } catch (error) {
        AppDebug.log('Primary audio asset failed ($candidate): $error');
      }
    }
    try {
      final data = await rootBundle.load('assets/$normalized');
      await _player.play(BytesSource(data.buffer.asUint8List()));
      return true;
    } catch (error) {
      AppDebug.log('Fallback audio bytes failed (assets/$normalized): $error');
      return false;
    }
  }

  Future<void> _stopLoop() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    try {
      await _player.stop();
    } on Exception catch (error) {
      AppDebug.log('Failed to stop victory audio loop: $error');
    } finally {
      _currentAudioAsset = null;
      _looping = false;
    }
  }

  Future<void> _disposeInternal() async {
    await _stopLoop();
    try {
      await _player.dispose();
    } on Exception catch (error) {
      AppDebug.log('Failed to dispose victory audio player: $error');
    }
  }
}
