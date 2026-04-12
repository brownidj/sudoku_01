import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/sudoku_screen_effects_service.dart';

class SudokuCorrectionFlowCoordinator {
  final SudokuScreenEffectsService _effectsService;

  const SudokuCorrectionFlowCoordinator(this._effectsService);

  Future<void> showPrompt({
    required BuildContext context,
    required bool Function() isMounted,
    required VoidCallback onConfirmCorrection,
    required VoidCallback onCorrectionConfirmed,
    required VoidCallback onDismissCorrectionPrompt,
    required UiState Function() currentState,
  }) async {
    final useCorrection = await _effectsService.showCorrectionPrompt(context);
    if (!isMounted()) {
      return;
    }
    if (!useCorrection) {
      onDismissCorrectionPrompt();
      return;
    }
    onConfirmCorrection();
    onCorrectionConfirmed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) {
        return;
      }
      _effectsService.showCorrectionNotice(context, currentState());
    });
  }
}
