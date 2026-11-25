import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
import 'package:flutter_app/ui/services/music_playback_diagnostics.dart';

class SudokuBackgroundMusicService {
  final AudioPlayer _player;
  final math.Random _random;
  final PremiumPolicyService _premiumPolicyService;
  final void Function(String trackAsset)? _onTrackPlayAttempt;
  StreamSubscription<void>? _completeSub;
  bool _audioEnabled = true;
  bool _backgroundMusicEnabled = false;
  bool _sessionInProgress = false;
  String _contentMode = 'numbers';
  bool _playing = false;
  bool _paused = false;
  bool _disposed = false;
  String? _loadedContentMode;
  String? _loadedAsset;
  Future<void> _operations = Future<void>.value();
  int _currentTrackIndex = -1;
  double _volume = 0.5;
  final Set<String> _suspensions = <String>{};

  SudokuBackgroundMusicService({
    AudioPlayer? player,
    math.Random? random,
    PremiumPolicyService premiumPolicyService = const PremiumPolicyService(),
    void Function(String trackAsset)? onTrackPlayAttempt,
  }) : _player = player ?? AudioPlayer(),
       _random = random ?? math.Random(),
       _premiumPolicyService = premiumPolicyService,
       _onTrackPlayAttempt = onTrackPlayAttempt {
    unawaited(
      _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
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
    _completeSub = _player.onPlayerComplete.listen((_) {
      unawaited(_enqueue(_playNextSequential));
    });
    unawaited(_player.setVolume(_volume));
  }
  void setAudioEnabled(bool enabled) {
    if (_audioEnabled == enabled) return;
    _audioEnabled = enabled;
    _syncPlayback();
  }

  void setBackgroundMusicEnabled(bool enabled) {
    if (_backgroundMusicEnabled == enabled) return;
    _backgroundMusicEnabled = enabled;
    _syncPlayback();
  }

  void setVolume(double volume) {
    final next = volume.clamp(0.0, 1.0);
    if (_volume == next) return;
    _volume = next;
    unawaited(_player.setVolume(_volume));
  }

  /// Installed pack paths become available asynchronously after game startup.
  Future<void> refreshInstalledTracks() async {
    if (!const ['marine', 'planets', 'buttons'].contains(_contentMode)) return;
    await _enqueue(() async {
      await _stop();
      _currentTrackIndex = -1;
      await _syncPlaybackNow();
    });
  }

  void onUiStateChanged(UiState state) {
    final inProgress = !state.gameOver;
    final nextContentMode = state.contentMode;
    final modeChanged = _contentMode != nextContentMode;
    if (_sessionInProgress == inProgress && !modeChanged) return;
    _sessionInProgress = inProgress;
    _contentMode = nextContentMode;
    if (modeChanged) {
      _currentTrackIndex = -1;
    }
    _syncPlayback();
  }

  void suspend(String reason) {
    if (_suspensions.add(reason)) _syncPlayback();
  }

  void resume(String reason) {
    if (_suspensions.remove(reason)) _syncPlayback();
  }

  Future<void> pickNewRandomTrack() => _enqueue(_pickNewRandomTrack);

  Future<void> _pickNewRandomTrack() async {
    if (_suspensions.isNotEmpty) return;
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (tracks.length <= 1) {
      await _playRandomStart();
      return;
    }
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _themeSupportsBackgroundMusic;
    if (!shouldPlay) return;
    var nextIndex = _currentTrackIndex;
    while (nextIndex == _currentTrackIndex) {
      nextIndex = _random.nextInt(tracks.length);
    }
    _currentTrackIndex = nextIndex;
    await _playCurrent();
  }

  Future<void> playNextTrack() => _enqueue(_nextTrack);

  Future<void> _nextTrack() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _themeSupportsBackgroundMusic &&
        _suspensions.isEmpty;
    if (!shouldPlay || tracks.isEmpty) return;
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = 0;
    } else {
      _currentTrackIndex = (_currentTrackIndex + 1) % tracks.length;
    }
    await _playCurrent();
  }

  Future<void> playPreviousTrack() => _enqueue(_previousTrack);

  Future<void> _previousTrack() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _themeSupportsBackgroundMusic &&
        _suspensions.isEmpty;
    if (!shouldPlay || tracks.isEmpty) return;
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = tracks.length - 1;
    } else {
      _currentTrackIndex =
          (_currentTrackIndex - 1 + tracks.length) % tracks.length;
    }
    await _playCurrent();
  }

  void dispose() {
    _disposed = true;
    unawaited(_disposeInternal());
  }

  void _syncPlayback() {
    unawaited(_enqueue(_syncPlaybackNow));
  }

  // Serialize native player commands so a slow pause/start cannot overtake
  // a later resume, preference change or theme switch.
  Future<void> _enqueue(Future<void> Function() action) {
    _operations = _operations
        .then((_) async {
          if (!_disposed) await action();
        })
        .catchError((Object error) {
          AppDebug.log('Background music operation failed: $error');
        });
    return _operations;
  }

  Future<void> _syncPlaybackNow() async {
    if (_loadedContentMode != null && _loadedContentMode != _contentMode) {
      await _stop();
    }
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: false,
    );
    if (!shouldPlay) {
      await _stop();
      return;
    }
    if (_suspensions.isNotEmpty) {
      if (_playing) {
        await _player.pause();
        _playing = false;
        _paused = true;
        await _recordPlayback('pause');
      }
      return;
    }
    if (_paused) {
      await _player.resume();
      _paused = false;
      _playing = true;
      await _recordPlayback('resume');
      return;
    }
    if (_playing) return;
    await _playRandomStart();
  }

  Future<void> _playRandomStart() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (tracks.isEmpty) return;
    _currentTrackIndex = _random.nextInt(tracks.length);
    await _playCurrent();
  }

  Future<void> _playNextSequential() async {
    _playing = false;
    _paused = false;
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: _suspensions.isNotEmpty,
    );
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (!shouldPlay || tracks.isEmpty) return _stop();
    _currentTrackIndex = (_currentTrackIndex + 1) % tracks.length;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: _suspensions.isNotEmpty,
    );
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (!shouldPlay || tracks.isEmpty) return;
    final asset = tracks[_currentTrackIndex];
    final contentMode = _contentMode;
    _onTrackPlayAttempt?.call(asset);
    AppDebug.log('Background music track: $asset');
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!await _playAssetWithFallback(asset)) {
        throw StateError('No playable source for asset $asset');
      }
      _playing = true;
      _paused = false;
      _loadedContentMode = contentMode;
      _loadedAsset = asset;
      await _recordPlayback('play');
    } catch (error) {
      AppDebug.log('Failed to play background music: $error');
      _playing = false;
    }
  }

  Future<bool> _playAssetWithFallback(String asset) async {
    if (asset.startsWith('/')) {
      await _player.play(DeviceFileSource(asset));
      return true;
    }
    final normalized = asset.startsWith('assets/')
        ? asset.substring('assets/'.length)
        : asset;
    for (final candidate in <String>{normalized, asset}) {
      try {
        await _player.play(AssetSource(candidate));
        return true;
      } catch (error) {
        AppDebug.log('Primary background asset failed ($candidate): $error');
      }
    }
    if (await _playBytesFromBundle('assets/$normalized')) {
      return true;
    }
    if (await _playBytesFromBundle('assets/$asset')) {
      return true;
    }
    if (await _playBytesFromBundle(normalized)) {
      return true;
    }
    if (await _playBytesFromBundle(asset)) {
      return true;
    }
    return false;
  }

  Future<bool> _playBytesFromBundle(String bundleKey) async {
    try {
      final data = await rootBundle.load(bundleKey);
      await _player.play(BytesSource(data.buffer.asUint8List()));
      return true;
    } catch (error) {
      AppDebug.log('Byte-source background asset failed ($bundleKey): $error');
      return false;
    }
  }

  Future<void> _stop() async {
    _playing = false;
    _paused = false;
    _loadedContentMode = null;
    _loadedAsset = null;
    try {
      await _player.stop();
    } catch (error) {
      AppDebug.log('Failed to stop background music: $error');
    }
  }

  Future<void> _disposeInternal() async {
    await _completeSub?.cancel();
    _completeSub = null;
    await _operations;
    await _stop();
    try {
      await _player.dispose();
    } catch (error) {
      AppDebug.log('Failed to dispose background music player: $error');
    }
  }

  bool get _themeSupportsBackgroundMusic =>
      _premiumPolicyService.isBackgroundMusicThemeMode(_contentMode);

  Future<void> _recordPlayback(String event) async {
    if (!MusicPlaybackDiagnostics.enabled) return;
    try {
      await MusicPlaybackDiagnostics.record(event, {
        'track': _loadedAsset?.split('/').last,
        'position_ms': (await _player.getCurrentPosition())?.inMilliseconds,
        'state': _player.state.name,
        'suspensions': _suspensions.toList(),
      });
    } catch (_) {
      /* Diagnostics must never affect playback. */
    }
  }
}
