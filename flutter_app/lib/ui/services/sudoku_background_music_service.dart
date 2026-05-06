import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';

class SudokuBackgroundMusicService {
  static const List<String> _tracks = <String>[
    'audio/background/Blue Morpho Lullaby-2.mp3',
    'audio/background/Blue Morpho Lullaby.mp3',
    'audio/background/Drifting Leaf Waltz-2.mp3',
    'audio/background/Drifting Leaf Waltz.mp3',
    'audio/background/Flamboyant Glide-2.mp3',
    'audio/background/Flamboyant Glide.mp3',
    'audio/background/Glasswing Glide-2.mp3',
    'audio/background/Glasswing Glide.mp3',
    'audio/background/Metamorphic Rave-2.mp3',
    'audio/background/Metamorphic Rave.mp3',
    'audio/background/Monarchs March-2.mp3',
    'audio/background/Monarchs March.mp3',
    'audio/background/Savannah Flutter-2.mp3',
    'audio/background/Savannah Flutter.mp3',
    'audio/background/Sulphur Shuffle-2.mp3',
    'audio/background/Sulphur Shuffle.mp3',
    'audio/background/Swallowtail Swoop-2.mp3',
    'audio/background/Swallowtail Swoop.mp3',
  ];

  final AudioPlayer _player;
  final math.Random _random;
  final void Function(String trackAsset)? _onTrackPlayAttempt;

  StreamSubscription<void>? _completeSub;
  bool _audioEnabled = true;
  bool _backgroundMusicEnabled = false;
  bool _sessionInProgress = false;
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
    if (_sessionInProgress == inProgress) {
      return;
    }
    _sessionInProgress = inProgress;
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
    if (_tracks.length <= 1) {
      await _playRandomStart();
      return;
    }
    final shouldPlay =
        _audioEnabled && _backgroundMusicEnabled && _sessionInProgress;
    if (!shouldPlay) {
      return;
    }
    var nextIndex = _currentTrackIndex;
    while (nextIndex == _currentTrackIndex) {
      nextIndex = _random.nextInt(_tracks.length);
    }
    _currentTrackIndex = nextIndex;
    await _playCurrent();
  }

  Future<void> playNextTrack() async {
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _suspensions.isEmpty;
    if (!shouldPlay || _tracks.isEmpty) {
      return;
    }
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = 0;
    } else {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
    }
    await _playCurrent();
  }

  Future<void> playPreviousTrack() async {
    final shouldPlay =
        _audioEnabled &&
        _backgroundMusicEnabled &&
        _sessionInProgress &&
        _suspensions.isEmpty;
    if (!shouldPlay || _tracks.isEmpty) {
      return;
    }
    if (_currentTrackIndex < 0) {
      _currentTrackIndex = _tracks.length - 1;
    } else {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
    }
    await _playCurrent();
  }

  void dispose() {
    unawaited(_disposeInternal());
  }

  void _syncPlayback() {
    final shouldPlay = shouldAttemptPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
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
    if (_tracks.isEmpty) {
      return;
    }
    _currentTrackIndex = _random.nextInt(_tracks.length);
    await _playCurrent();
  }

  Future<void> _playNextSequential() async {
    final shouldPlay = shouldAttemptPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      hasSuspensions: false,
    );
    if (!shouldPlay || _tracks.isEmpty) {
      await _stop();
      return;
    }
    _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final shouldPlay = shouldAttemptPlayback(
      audioEnabled: _audioEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
      sessionInProgress: _sessionInProgress,
      hasSuspensions: false,
    );
    if (!shouldPlay || _tracks.isEmpty) {
      return;
    }
    final asset = _tracks[_currentTrackIndex];
    _onTrackPlayAttempt?.call(asset);
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!await _playAssetWithFallback(asset)) {
        throw StateError('No playable source for asset $asset');
      }
      _playing = true;
    } on Exception catch (error) {
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
      return false;
    }
  }

  Future<void> _stop() async {
    _playing = false;
    try {
      await _player.stop();
    } on Exception catch (error) {
      AppDebug.log('Failed to stop background music: $error');
    }
  }

  Future<void> _disposeInternal() async {
    await _completeSub?.cancel();
    _completeSub = null;
    await _stop();
    try {
      await _player.dispose();
    } on Exception catch (error) {
      AppDebug.log('Failed to dispose background music player: $error');
    }
  }

  static bool shouldAttemptPlayback({
    required bool audioEnabled,
    required bool backgroundMusicEnabled,
    required bool sessionInProgress,
    required bool hasSuspensions,
  }) {
    return audioEnabled &&
        backgroundMusicEnabled &&
        sessionInProgress &&
        !hasSuspensions;
  }
}
