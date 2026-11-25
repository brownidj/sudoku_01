import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_cell_tooltip_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/theme/marine_game_theme.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOverlay implements CellTooltipOverlay {
  int showCalls = 0;
  String? lastImageAssetPath;
  String? lastText;

  @override
  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
    String? imageAssetPath,
  }) {
    showCalls += 1;
    lastText = text;
    lastImageAssetPath = imageAssetPath;
  }
}

class _FakeAudioController implements TilePreviewAudioController {
  _FakeAudioController({required this.hasAudioAsset, required this.playResult});

  final bool hasAudioAsset;
  final bool playResult;

  int playCalls = 0;
  String? lastMode;
  int? lastDigit;

  @override
  String? audioAssetForTile({required String contentMode, required int digit}) {
    return hasAudioAsset ? 'mock-asset' : null;
  }

  @override
  Duration get maxClipDuration => const Duration(seconds: 4);

  @override
  bool playForTile({required String contentMode, required int digit}) {
    playCalls += 1;
    lastMode = contentMode;
    lastDigit = digit;
    return playResult;
  }
}

class _FakeBackgroundMusicController implements BackgroundMusicController {
  int suspendCalls = 0;
  int resumeCalls = 0;
  String? lastSuspendReason;
  String? lastResumeReason;

  @override
  void resume(String reason) {
    resumeCalls += 1;
    lastResumeReason = reason;
  }

  @override
  void suspend(String reason) {
    suspendCalls += 1;
    lastSuspendReason = reason;
  }
}

UiState _stateWithValue({required String contentMode, required int value}) {
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => List<CellVm>.generate(
      9,
      (c) => CellVm(
        coord: Coord(r, c),
        value: null,
        given: false,
        notes: const [],
        selected: false,
        conflicted: false,
        incorrect: false,
        solutionAdded: false,
        correct: false,
        reverted: false,
      ),
      growable: false,
    ),
    growable: false,
  );
  cells[0][0] = CellVm(
    coord: const Coord(0, 0),
    value: value,
    given: false,
    notes: const [],
    selected: false,
    conflicted: false,
    incorrect: false,
    solutionAdded: false,
    correct: false,
    reverted: false,
  );
  return UiState(
    board: BoardVm(cells: cells),
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: contentMode,
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    puzzleSolved: false,
    correctionsLeft: 3,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    conflictHintsLeft: 3,
  );
}

void main() {
  tearDown(() => MarineGameTheme.definition = null);

  for (final mode in ['butterflies', 'marine']) {
    for (final soundState in ['enabled', 'muted', 'missing']) {
      final soundEnabled = soundState == 'enabled';
      testWidgets(
        '$mode board long press shows image and name with audio $soundState',
        (tester) async {
          if (mode == 'marine') {
            MarineGameTheme.definition = ThemeDefinition(
              id: 'marine',
              displayName: 'Marine Life',
              version: 2,
              tiles: [
                for (var i = 1; i <= 9; i++)
                  ThemeTile(
                    id: '$i',
                    imagePath: File(
                      'assets/images/marine/7_blackback_butterflyfish.png',
                    ).absolute.path,
                    accessibilityLabel: 'Blackback Butterfly Fish',
                    displayName: 'Blackback Butterfly Fish',
                    label: '$i',
                  ),
              ],
              audio: null,
              colours: const ThemeColours(),
              typography: null,
            );
          }
          final overlay = TooltipOverlayService();
          addTearDown(overlay.dispose);
          final audio = _FakeAudioController(
            hasAudioAsset: soundState != 'missing',
            playResult: soundEnabled,
          );
          final background = _FakeBackgroundMusicController();
          final service = SudokuCellTooltipService(
            TooltipOverlayAdapter(overlay),
            audio,
            background,
          );
          final state = _stateWithValue(
            contentMode: mode,
            value: mode == 'marine' ? 7 : 1,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: SizedBox(
                      width: 360,
                      height: 360,
                      child: SudokuBoard(
                        state: state,
                        style: styleModern,
                        animalImages: const {},
                        noteImagesBySize: const {},
                        devicePixelRatio: 1,
                        onTapCell: (_) {},
                        onLongPressCell: (position, coord) =>
                            service.showForCell(
                              context: context,
                              state: state,
                              coord: coord,
                              globalPosition: position,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Exercise the real gesture recognizer, board coordinate mapping,
          // service and overlay together, rather than calling showForCell alone.
          final topLeft = tester.getTopLeft(find.byType(SudokuBoard));
          await tester.longPressAt(topLeft + const Offset(20, 20));
          await tester.pump();
          final preview = find.byKey(const ValueKey('tile-preview-overlay'));
          expect(preview, findsOneWidget);
          expect(
            find.descendant(
              of: preview,
              matching: find.text(
                mode == 'marine' ? 'Blackback Butterfly Fish' : 'Monarch',
              ),
            ),
            findsOneWidget,
          );
          final image = tester.widget<Image>(
            find.descendant(of: preview, matching: find.byType(Image)),
          );
          if (mode == 'marine') {
            expect(image.image, isA<FileImage>());
            expect(
              (image.image as FileImage).file.path,
              endsWith('/7_blackback_butterflyfish.png'),
            );
          } else {
            expect(image.image, isA<AssetImage>());
            expect(
              (image.image as AssetImage).assetName,
              'assets/images/butterflies/1_monarch.png',
            );
          }
          expect(audio.playCalls, soundState == 'missing' ? 0 : 1);
          if (soundState != 'missing') {
            expect(audio.lastMode, mode);
            expect(audio.lastDigit, mode == 'marine' ? 7 : 1);
          }
          expect(background.suspendCalls, soundEnabled ? 1 : 0);
          await tester.pump(const Duration(seconds: 3));
          expect(preview, findsOneWidget);
          await tester.pump(const Duration(seconds: 1));
          expect(preview, findsNothing);
          expect(background.resumeCalls, soundEnabled ? 1 : 0);
        },
      );
    }
  }

  testWidgets(
    'butterfly tile long press shows large image preview and triggers audio',
    (tester) async {
      final overlay = _FakeOverlay();
      final audio = _FakeAudioController(hasAudioAsset: true, playResult: true);
      final background = _FakeBackgroundMusicController();
      final service = SudokuCellTooltipService(overlay, audio, background);

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      service.showForCell(
        context: context,
        state: _stateWithValue(contentMode: 'butterflies', value: 1),
        coord: const Coord(0, 0),
        globalPosition: const Offset(100, 120),
      );
      await tester.pump();

      expect(overlay.showCalls, 1);
      expect(
        overlay.lastImageAssetPath,
        'assets/images/butterflies/1_monarch.png',
      );
      expect(audio.playCalls, 1);
      expect(audio.lastMode, 'butterflies');
      expect(audio.lastDigit, 1);
      expect(find.text('Monarch'), findsOneWidget);
      expect(background.suspendCalls, 1);
      expect(background.lastSuspendReason, 'tile-preview');
      expect(find.textContaining('Audio is not available'), findsNothing);
      await tester.pump(audio.maxClipDuration);
      expect(background.resumeCalls, 1);
      expect(background.lastResumeReason, 'tile-preview');
    },
  );

  testWidgets('another preview keeps music paused until the latest clip ends', (
    tester,
  ) async {
    final audio = _FakeAudioController(hasAudioAsset: true, playResult: true);
    final background = _FakeBackgroundMusicController();
    final service = SudokuCellTooltipService(_FakeOverlay(), audio, background);
    addTearDown(service.dispose);
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    void preview() => service.showForCell(
      context: context,
      state: _stateWithValue(contentMode: 'butterflies', value: 1),
      coord: const Coord(0, 0),
      globalPosition: const Offset(100, 120),
    );
    preview();
    await tester.pump(const Duration(seconds: 3));
    preview();
    await tester.pump(const Duration(seconds: 1));
    expect(background.resumeCalls, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(background.suspendCalls, 2);
    expect(background.resumeCalls, 1);
    expect(background.lastResumeReason, 'tile-preview');
  });

  testWidgets('shows snackbar when tile audio is unavailable', (tester) async {
    final overlay = _FakeOverlay();
    final audio = _FakeAudioController(hasAudioAsset: false, playResult: false);
    final background = _FakeBackgroundMusicController();
    final service = SudokuCellTooltipService(overlay, audio, background);

    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    service.showForCell(
      context: context,
      state: _stateWithValue(contentMode: 'animals', value: 1),
      coord: const Coord(0, 0),
      globalPosition: const Offset(80, 100),
    );
    await tester.pump();

    expect(
      find.text('Audio is not available for this tile yet.'),
      findsOneWidget,
    );
    expect(find.text('Ape'), findsNothing);
    expect(background.suspendCalls, 0);
  });
}
