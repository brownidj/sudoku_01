import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/sudoku_cell_tooltip_service.dart';
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
  _FakeAudioController({
    required this.hasAudioAsset,
    required this.playResult,
    this.maxDuration = const Duration(seconds: 4),
  });

  final bool hasAudioAsset;
  final bool playResult;
  final Duration maxDuration;

  int playCalls = 0;
  String? lastMode;
  int? lastDigit;

  @override
  String? audioAssetForTile({required String contentMode, required int digit}) {
    return hasAudioAsset ? 'mock-asset' : null;
  }

  @override
  Duration get maxClipDuration => maxDuration;

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

UiState _stateWithValue({
  required String contentMode,
  required int value,
}) {
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

      expect(overlay.showCalls, 1);
      expect(
        overlay.lastImageAssetPath,
        'assets/images/butterflies/1_monarch.png',
      );
      expect(audio.playCalls, 1);
      expect(audio.lastMode, 'butterflies');
      expect(audio.lastDigit, 1);
      expect(background.suspendCalls, 1);
      expect(background.lastSuspendReason, 'tile-preview');
      expect(find.textContaining('Audio is not available'), findsNothing);
      await tester.pump(audio.maxClipDuration);
      expect(background.resumeCalls, 1);
      expect(background.lastResumeReason, 'tile-preview');
    },
  );

  testWidgets('shows snackbar when tile audio is unavailable', (tester) async {
    final overlay = _FakeOverlay();
    final audio = _FakeAudioController(
      hasAudioAsset: false,
      playResult: false,
    );
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

    expect(find.text('Audio is not available for this tile yet.'), findsOneWidget);
    expect(background.suspendCalls, 0);
  });
}
