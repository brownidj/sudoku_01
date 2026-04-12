import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';

class SudokuVictoryAudioService {
  final AudioPlayer _player;

  String? _currentAudioAsset;
  bool _looping = false;
  bool _enabled = true;

  SudokuVictoryAudioService({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

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
    final lower = mascotAssetPath.toLowerCase();
    if (lower.contains('ape')) {
      return 'audio/apes.mp3';
    }
    if (lower.contains('buffalo')) {
      return 'audio/buffalo.mp3';
    }
    // "camel" has no dedicated clip; use the digit-3 legacy animal sound.
    if (lower.contains('camel')) {
      return 'audio/cheetah.mp3';
    }
    if (lower.contains('dolphin')) {
      return 'audio/dolphin.mp3';
    }
    if (lower.contains('elephant')) {
      return 'audio/elephant.mp3';
    }
    if (lower.contains('frog')) {
      return 'audio/frog.mp3';
    }
    if (lower.contains('giraffe')) {
      return 'audio/giraffe.mp3';
    }
    if (lower.contains('hippo')) {
      return 'audio/hippos.mp3';
    }
    if (lower.contains('iguana')) {
      return 'audio/iguana.mp3';
    }
    return null;
  }

  Future<void> _playLoop(String audioAsset) async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(audioAsset));
      _currentAudioAsset = audioAsset;
      _looping = true;
    } on Exception catch (error) {
      AppDebug.log('Failed to play victory audio loop: $error');
      _currentAudioAsset = null;
      _looping = false;
    }
  }

  Future<void> _stopLoop() async {
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
