import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';

class SudokuTilePreviewAudioService {
  final AudioPlayer _player;
  final Duration _maxClipDuration;

  bool _enabled = true;
  double _volume = 0.5;
  Timer? _autoStopTimer;

  SudokuTilePreviewAudioService({
    AudioPlayer? player,
    Duration maxClipDuration = const Duration(seconds: 4),
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
    if (digit < 1 || digit > 9) {
      return null;
    }
    return BundledThemeRepository.tilePreviewAudioAsset(
      themeId: contentMode,
      digit: digit,
    );
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
    } catch (error) {
      AppDebug.log('Failed to play tile preview audio: $error');
    }
  }

  Future<bool> _playAssetWithFallback(String asset) async {
    final normalized = asset.startsWith('assets/')
        ? asset.substring('assets/'.length)
        : asset;
    for (final candidate in <String>{normalized, asset}) {
      try {
        await _player.play(AssetSource(candidate));
        return true;
      } catch (error) {
        AppDebug.log('Primary tile audio asset failed ($candidate): $error');
      }
    }
    try {
      final data = await rootBundle.load('assets/$normalized');
      await _player.play(BytesSource(data.buffer.asUint8List()));
      return true;
    } catch (error) {
      AppDebug.log(
        'Fallback tile audio bytes failed (assets/$normalized): $error',
      );
      return false;
    }
  }

  Future<void> _stop() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    try {
      await _player.stop();
    } catch (error) {
      AppDebug.log('Failed to stop tile preview audio: $error');
    }
  }

  Future<void> _disposeInternal() async {
    await _stop();
    try {
      await _player.dispose();
    } catch (error) {
      AppDebug.log('Failed to dispose tile preview audio player: $error');
    }
  }
}
