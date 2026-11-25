import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_background_music_service.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

class _State extends Fake implements UiState {
  _State(this.contentMode, {this.gameOver = false});
  @override
  final String contentMode;
  @override
  final bool gameOver;
}

class _Player extends Fake implements AudioPlayer {
  final completions = StreamController<void>.broadcast();
  final calls = <String>[];
  Source? currentSource;
  Duration position = Duration.zero;
  Completer<void>? pauseGate;
  @override
  Stream<void> get onPlayerComplete => completions.stream;
  @override
  Future<void> setAudioContext(AudioContext context) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {}
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    calls.add('play');
    currentSource = source;
    this.position = position ?? Duration.zero;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    position = Duration.zero;
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    await pauseGate?.future;
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> dispose() async {
    await completions.close();
  }
}

void main() {
  late _Player player;
  late SudokuBackgroundMusicService service;
  setUp(() {
    MarineGameTheme.definition = const ThemeDefinition(
      id: 'marine',
      displayName: 'Marine Life',
      version: 4,
      tiles: [],
      audio: ThemeAudio(
        backgroundMusicAssets: [
          '/installed/threadfin.mp3',
          '/installed/redtail.m4a',
        ],
      ),
      colours: ThemeColours(),
      typography: null,
    );
    player = _Player();
  });
  tearDown(() {
    service.dispose();
    MarineGameTheme.definition = null;
  });

  Future<void> start(WidgetTester tester) async {
    service = SudokuBackgroundMusicService(player: player, random: Random(42));
    service.onUiStateChanged(_State('marine'));
    service.setBackgroundMusicEnabled(true);
    await tester.pump();
    expect(player.calls, contains('play'));
    player.position = const Duration(seconds: 37);
    player.calls.clear();
  }

  testWidgets(
    'preview pauses and resumes same source and position without play, stop or seek',
    (tester) async {
      await start(tester);
      final source = player.currentSource;
      service.suspend('tile-preview');
      await tester.pump();
      expect(player.calls, ['pause']);
      service.resume('tile-preview');
      await tester.pump();
      expect(player.calls, ['pause', 'resume']);
      expect(player.currentSource, same(source));
      expect(player.position, const Duration(seconds: 37));
    },
  );

  testWidgets(
    'nested suspensions and track controls cannot restart paused music',
    (tester) async {
      await start(tester);
      service.suspend('tile-preview');
      await tester.pump();
      service.suspend('victory');
      service.resume('tile-preview');
      await service.pickNewRandomTrack();
      await service.playNextTrack();
      await service.playPreviousTrack();
      await tester.pump();
      expect(player.calls, ['pause']);
      service.resume('victory');
      await tester.pump();
      expect(player.calls, ['pause', 'resume']);
    },
  );

  for (final disable in ['audio', 'music', 'game', 'theme']) {
    testWidgets('$disable change during preview prevents stale-track resume', (
      tester,
    ) async {
      await start(tester);
      service.suspend('tile-preview');
      await tester.pump();
      switch (disable) {
        case 'audio':
          service.setAudioEnabled(false);
        case 'music':
          service.setBackgroundMusicEnabled(false);
        case 'game':
          service.onUiStateChanged(_State('marine', gameOver: true));
        case 'theme':
          service.onUiStateChanged(_State('numbers'));
      }
      await tester.pump();
      service.resume('tile-preview');
      await tester.pump();
      expect(player.calls, isNot(contains('resume')));
      expect(player.calls, contains('stop'));
    });
  }

  testWidgets(
    'resume waits for pending native pause and keeps the same track',
    (tester) async {
      await start(tester);
      player.pauseGate = Completer<void>();
      service.suspend('tile-preview');
      await tester.pump();
      service.resume('tile-preview');
      await tester.pump();
      expect(player.calls, ['pause']);
      player.pauseGate!.complete();
      await tester.pump();
      expect(player.calls, ['pause', 'resume']);
      expect(player.position, const Duration(seconds: 37));
    },
  );
}
