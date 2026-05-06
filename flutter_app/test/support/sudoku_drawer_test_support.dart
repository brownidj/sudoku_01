import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';

UiState drawerState({bool premiumActive = false}) {
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

  return UiState(
    board: BoardVm(cells: cells),
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    correctionsLeft: 5,
    canUndo: false,
    correctionPromptCoord: null,
    debugScenarioLabel: null,
    correctionNoticeSerial: 0,
    correctionNoticeMessage: null,
    entitlement: premiumActive ? Entitlement.premium : Entitlement.free,
    premiumActive: premiumActive,
  );
}

Widget drawerHarness({
  bool premiumActive = false,
  bool audioEnabled = true,
  bool backgroundMusicEnabled = true,
  double audioVolume = 0.5,
  ValueChanged<bool>? onAudioEnabledChanged,
  ValueChanged<bool>? onBackgroundMusicEnabledChanged,
  ValueChanged<double>? onAudioVolumeChanged,
  VoidCallback? onLoadCorrectionScenario,
  VoidCallback? onLoadExhaustedCorrectionScenario,
  VoidCallback? onResetEntitlementToFreeSelected,
  VoidCallback? onRestorePurchasesSelected,
  bool showDebugTools = false,
}) {
  return MaterialApp(
    home: SudokuDrawer(
      state: drawerState(premiumActive: premiumActive),
      onAnimalStyleChanged: (_) {},
      onStyleChanged: (_) {},
      audioEnabled: audioEnabled,
      onAudioEnabledChanged: onAudioEnabledChanged,
      backgroundMusicEnabled: backgroundMusicEnabled,
      onBackgroundMusicEnabledChanged: onBackgroundMusicEnabledChanged,
      audioVolume: audioVolume,
      onAudioVolumeChanged: onAudioVolumeChanged,
      onLoadCorrectionScenario: onLoadCorrectionScenario,
      onLoadExhaustedCorrectionScenario: onLoadExhaustedCorrectionScenario,
      onResetEntitlementToFreeSelected: onResetEntitlementToFreeSelected,
      onRestorePurchasesSelected: onRestorePurchasesSelected,
      showDebugTools: showDebugTools,
    ),
  );
}
