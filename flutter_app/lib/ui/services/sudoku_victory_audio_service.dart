import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';

class SudokuVictoryAudioService {
  final AudioPlayer _player;
  final Duration _maxLoopDuration;

  String? _currentAudioAsset;
  bool _looping = false;
  bool _enabled = true;
  Timer? _autoStopTimer;

  SudokuVictoryAudioService({
    AudioPlayer? player,
    Duration maxLoopDuration = const Duration(seconds: 6),
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
      'accordion.png': 'audio/music/accordion.mp3',
      'banjo.png': 'audio/music/banjo.mp3',
      'maracas.png': 'audio/music/maracas.mp3',
      'drum.png': 'audio/music/drum.mp3',
      'horn.png': 'audio/music/horn.mp3',
      'piano.png': 'audio/music/piano.mp3',
      'saxaphone.png': 'audio/music/saxophone.mp3',
      'saxophone.png': 'audio/music/saxophone.mp3',
      'tambourine.png': 'audio/music/tambourine.mp3',
      'trumpet.png': 'audio/music/trumpet.mp3',
      'ukelele.png': 'audio/music/ukulele.mp3',
      'ukulele.png': 'audio/music/ukulele.mp3',
      'violin.png': 'audio/music/violin.mp3',
    };
    final mapped = explicitMap[fileName];
    if (mapped != null) {
      return mapped;
    }
    if (lower.contains('saxaphone') || lower.contains('saxophone')) {
      return 'audio/music/saxophone.mp3';
    }
    return null;
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
      AppDebug.log('Failed to play victory audio loop ($audioAsset): $error');
      _currentAudioAsset = null;
      _looping = false;
    }
  }

  Future<bool> _playAssetWithFallback(String audioAsset) async {
    try {
      await _player.play(AssetSource(audioAsset));
      return true;
    } catch (error) {
      AppDebug.log('Primary audio asset failed ($audioAsset): $error');
      // Some platforms/builds may require the explicit assets/ prefix.
    }

    try {
      await _player.play(AssetSource('assets/$audioAsset'));
      return true;
    } catch (error) {
      AppDebug.log('Fallback audio asset failed (assets/$audioAsset): $error');
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
