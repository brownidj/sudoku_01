import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/app_debug.dart';

class SudokuTilePreviewAudioService {
  final AudioPlayer _player;
  final Duration _maxClipDuration;

  bool _enabled = true;
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

  void playForTile({
    required String contentMode,
    required int digit,
  }) {
    if (!_enabled) {
      return;
    }
    final asset = audioAssetForTile(contentMode: contentMode, digit: digit);
    if (asset == null) {
      return;
    }
    unawaited(_play(asset));
  }

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
    return switch (normalizedMode) {
      'animals' => animalAssets[digit],
      'instruments' => instrumentAssets[digit],
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
