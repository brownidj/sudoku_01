import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_service.dart';

class SudokuScreenEffectsCoordinator {
  final SudokuScreenEffectsService _effectsService;

  const SudokuScreenEffectsCoordinator(this._effectsService);

  void onStateChanged({
    required BuildContext context,
    required UiState state,
    required bool Function() isMounted,
    required Future<void> Function() showCorrectionPrompt,
    required VoidCallback showCorrectionNotice,
  }) {
    if (_effectsService.shouldScheduleCorrectionPrompt(
      state.correctionPromptCoord,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isMounted()) {
          return;
        }
        showCorrectionPrompt();
      });
    }
    if (_effectsService.shouldScheduleCorrectionNotice(
      serial: state.correctionNoticeSerial,
      message: state.correctionNoticeMessage,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isMounted()) {
          return;
        }
        showCorrectionNotice();
      });
    }
  }
}
