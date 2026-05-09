import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_tracks.dart';
class SudokuBackgroundMusicService {
  final AudioPlayer _player;
  final math.Random _random;
  final void Function(String trackAsset)? _onTrackPlayAttempt;
  StreamSubscription<void>? _completeSub;
  bool _audioEnabled = true;
  bool _backgroundMusicEnabled = false;
  bool _sessionInProgress = false;
  String _contentMode = 'numbers';
  bool _playing = false;
  int _currentTrackIndex = -1;
  double _volume = 0.5;
  final Set<String> _suspensions = <String>{};

  SudokuBackgroundMusicService({
    AudioPlayer? player,
    math.Random? random,
    void Function(String trackAsset)? onTrackPlayAttempt,
  })
    : _player = player ?? AudioPlayer(),
      _random = random ?? math.Random(),
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
      unawaited(_playNextSequential());
    });
    unawaited(_player.setVolume(_volume));
  }
  void setAudioEnabled(bool enabled) {
    if (_audioEnabled == enabled) {
      return;
    }
    _audioEnabled = enabled;
    _syncPlayback();
  }
  void setBackgroundMusicEnabled(bool enabled) {
    if (_backgroundMusicEnabled == enabled) {
      return;
    }
    _backgroundMusicEnabled = enabled;
    _syncPlayback();
  }
  void setVolume(double volume) {
    final next = volume.clamp(0.0, 1.0);
    if (_volume == next) {
      return;
    }
    _volume = next;
    unawaited(_player.setVolume(_volume));
  }
  void onUiStateChanged(UiState state) {
    final inProgress = !state.gameOver;
    final nextContentMode = state.contentMode;
    final modeChanged = _contentMode != nextContentMode;
    if (_sessionInProgress == inProgress &&
        !modeChanged) {
      return;
    }
    _sessionInProgress = inProgress;
    _contentMode = nextContentMode;
    if (modeChanged) {
      _currentTrackIndex = -1;
      final shouldPlayNow = shouldAttemptBackgroundMusicPlayback(
        audioEnabled: _audioEnabled,
        backgroundMusicEnabled: _backgroundMusicEnabled,
        sessionInProgress: _sessionInProgress,
        themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
        hasSuspensions: _suspensions.isNotEmpty,
      );
      if (shouldPlayNow) {
        unawaited(_playRandomStart());
        return;
      }
    }
    _syncPlayback();
  }

  void suspend(String reason) {
    if (_suspensions.add(reason)) {
      _syncPlayback();
    }
  }

  void resume(String reason) {
    if (_suspensions.remove(reason)) {
      _syncPlayback();
    }
  }

  Future<void> pickNewRandomTrack() async {
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
    if (!shouldPlay) {
      return;
    }
    var nextIndex = _currentTrackIndex;
    while (nextIndex == _currentTrackIndex) {
      nextIndex = _random.nextInt(tracks.length);
    }
    _currentTrackIndex = nextIndex;
    await _playCurrent();
  }

  Future<void> playNextTrack() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _themeSupportsBackgroundMusic &&
        _suspensions.isEmpty;
    if (!shouldPlay || tracks.isEmpty) {
      return;
    }
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = 0;
    } else {
      _currentTrackIndex = (_currentTrackIndex + 1) % tracks.length;
    }
    await _playCurrent();
  }

  Future<void> playPreviousTrack() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _themeSupportsBackgroundMusic &&
        _suspensions.isEmpty;
    if (!shouldPlay || tracks.isEmpty) {
      return;
    }
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = tracks.length - 1;
    } else {
      _currentTrackIndex = (_currentTrackIndex - 1 + tracks.length) % tracks.length;
    }
    await _playCurrent();
  }

  void dispose() {
    unawaited(_disposeInternal());
  }

  void _syncPlayback() {
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: _suspensions.isNotEmpty,
    );
    if (!shouldPlay) {
      unawaited(_stop());
      return;
    }
    if (_playing) {
      return;
    }
    unawaited(_playRandomStart());
  }

  Future<void> _playRandomStart() async {
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (tracks.isEmpty) {
      return;
    }
    _currentTrackIndex = _random.nextInt(tracks.length);
    await _playCurrent();
  }

  Future<void> _playNextSequential() async {
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: false,
    );
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (!shouldPlay || tracks.isEmpty) {
      await _stop();
      return;
    }
    _currentTrackIndex = (_currentTrackIndex + 1) % tracks.length;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final shouldPlay = shouldAttemptBackgroundMusicPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      themeSupportsBackgroundMusic: _themeSupportsBackgroundMusic,
      hasSuspensions: false,
    );
    final tracks = backgroundTracksForContentMode(_contentMode);
    if (!shouldPlay || tracks.isEmpty) {
      return;
    }
    final asset = tracks[_currentTrackIndex];
    _onTrackPlayAttempt?.call(asset);
    AppDebug.log('Background music track: $asset');
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!await _playAssetWithFallback(asset)) {
        throw StateError('No playable source for asset $asset');
      }
      _playing = true;
    } catch (error) {
      AppDebug.log('Failed to play background music: $error');
      _playing = false;
    }
  }

  Future<bool> _playAssetWithFallback(String asset) async {
    try {
      await _player.play(AssetSource(asset));
      return true;
    } catch (error) {
      AppDebug.log('Primary background asset failed ($asset): $error');
    }
    try {
      await _player.play(AssetSource('assets/$asset'));
      return true;
    } catch (error) {
      AppDebug.log('Fallback background asset failed (assets/$asset): $error');
    }
    if (await _playBytesFromBundle('assets/$asset')) {
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
    try {
      await _player.stop();
    } catch (error) {
      AppDebug.log('Failed to stop background music: $error');
    }
  }

  Future<void> _disposeInternal() async {
    await _completeSub?.cancel();
    _completeSub = null;
    await _stop();
    try {
      await _player.dispose();
    } catch (error) {
      AppDebug.log('Failed to dispose background music player: $error');
    }
  }
  bool get _themeSupportsBackgroundMusic =>
      _contentMode == 'butterflies' || _contentMode == 'old_opera';
}
