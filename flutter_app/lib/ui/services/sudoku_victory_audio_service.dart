import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';
import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';

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
    return BundledThemeRepository.celebrationAudioAssetForImagePath(
      mascotAssetPath,
    );
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
