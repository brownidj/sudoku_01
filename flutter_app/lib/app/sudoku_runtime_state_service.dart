import 'package:flutter_app/app/correction_state.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_runtime_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class SudokuRuntimeStateService {
  const SudokuRuntimeStateService();

  UiState buildState({
    required SudokuRuntimeState runtime,
    required SettingsState settings,
    required UiStateMapper uiStateMapper,
    required Entitlement entitlement,
    required bool premiumActive,
  }) {
    return uiStateMapper.map(
      UiStateMapperInput(
        board: runtime.history.present.board,
        settings: settings,
        selected: runtime.selected,
        conflicts: runtime.lastConflicts,
        incorrectCells: runtime.incorrectCells,
        correctCells: runtime.correctCells,
        solutionAddedCells: runtime.solutionAddedCells,
        solutionGrid: runtime.solutionGrid,
        gameOver: runtime.gameOver,
        puzzleSolved: runtime.puzzleSolved,
        revertedCells: runtime.correctionState.revertedCells,
        correctionsLeft: runtime.correctionState.tokensLeft,
        canUndo: runtime.history.canUndo(),
        correctionPromptCoord: runtime.correctionState.pendingPromptCoord,
        debugScenarioLabel: runtime.debugScenarioLabel,
        correctionNoticeSerial: runtime.correctionNoticeSerial,
        correctionNoticeMessage: runtime.correctionNoticeMessage,
        conflictHintsLeft: runtime.conflictHintsLeft,
        entitlement: entitlement,
        premiumActive: premiumActive,
        puzzleStartedAt: runtime.puzzleStartedAt,
        puzzleFinishedAt: runtime.puzzleFinishedAt,
        activeElapsedSeconds: runtime.activeElapsedSeconds,
        activeTimingStartedAt: runtime.activeTimingStartedAt,
      ),
    );
  }

  Set<Coord> givenCoords(History history) {
    final givens = <Coord>{};
    final board = history.present.board;
    for (var r = 0; r < 9; r += 1) {
      for (var col = 0; col < 9; col += 1) {
        if (board.cellAt(r, col).given) {
          givens.add(Coord(r, col));
        }
      }
    }
    return givens;
  }

  void clearCorrectionPromptState(
    SudokuRuntimeState runtime, {
    required bool clearRevertedCells,
  }) {
    runtime.correctionState = runtime.correctionState.copyWith(
      pendingPromptCoord: null,
      revertedCells: clearRevertedCells
          ? const {}
          : runtime.correctionState.revertedCells,
    );
  }

  void resetBoardFlags(
    SudokuRuntimeState runtime,
    SettingsController settings,
  ) {
    runtime
      ..selected = null
      ..lastConflicts = {}
      ..gameOver = false
      ..puzzleSolved = false
      ..incorrectCells = {}
      ..solutionAddedCells = {}
      ..correctCells = {}
      ..solutionGrid = null
      ..debugScenarioLabel = null
      ..correctionNoticeMessage = null
      ..conflictHintsLeft = conflictHintsForDifficulty(
        settings.state.difficulty,
      )
      ..puzzleStartedAt = DateTime.now()
      ..puzzleFinishedAt = null
      ..activeElapsedSeconds = 0
      ..activeTimingStartedAt = DateTime.now();
    settings.setDifficultyLocked(false);
    settings.setPuzzleModeLocked(false);
    clearCorrectionPromptState(runtime, clearRevertedCells: true);
  }

  void applyRestoredSettings(
    SettingsController settingsController,
    SettingsState settings,
  ) {
    settingsController.setDifficultyLocked(false);
    settingsController.setPuzzleModeLocked(false);
    settingsController.setStyleName(settings.styleName);
    settingsController.setContentMode(settings.contentMode);
    settingsController.setAnimalStyle(settings.animalStyle);
    settingsController.setNotesMode(settings.notesMode);
    settingsController.setDifficulty(settings.difficulty);
    settingsController.setPuzzleMode(settings.puzzleMode);
    settingsController.setDifficultyLocked(!settings.canChangeDifficulty);
    settingsController.setPuzzleModeLocked(!settings.canChangePuzzleMode);
  }

  CorrectionState initialCorrectionState({
    required String difficulty,
    required History history,
  }) {
    return CorrectionState.initial(difficulty: difficulty, history: history);
  }

  int activeElapsedSeconds(SudokuRuntimeState runtime, {DateTime? now}) {
    final startedAt = runtime.activeTimingStartedAt;
    if (startedAt == null) {
      return runtime.activeElapsedSeconds;
    }
    final delta = (now ?? DateTime.now()).difference(startedAt).inSeconds;
    final cappedDelta = delta.clamp(0, activePlayIdleTimeout.inSeconds).toInt();
    return runtime.activeElapsedSeconds + cappedDelta;
  }

  void registerActiveUse(SudokuRuntimeState runtime, {DateTime? now}) {
    if (!_canTrackActiveTime(runtime)) {
      return;
    }
    pauseActiveTiming(runtime, now: now);
    runtime.activeTimingStartedAt = now ?? DateTime.now();
  }

  void pauseActiveTiming(SudokuRuntimeState runtime, {DateTime? now}) {
    runtime.activeElapsedSeconds = activeElapsedSeconds(runtime, now: now);
    runtime.activeTimingStartedAt = null;
  }

  void resumeActiveTiming(SudokuRuntimeState runtime, {DateTime? now}) {
    if (!_canTrackActiveTime(runtime)) {
      runtime.activeTimingStartedAt = null;
      return;
    }
    pauseActiveTiming(runtime, now: now);
    runtime.activeTimingStartedAt = now ?? DateTime.now();
  }

  bool _canTrackActiveTime(SudokuRuntimeState runtime) {
    return !runtime.gameOver &&
        !runtime.puzzleSolved &&
        runtime.puzzleFinishedAt == null;
  }
}
