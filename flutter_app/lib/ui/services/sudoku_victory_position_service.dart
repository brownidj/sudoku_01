import 'package:flutter/material.dart';
import 'package:flutter_app/ui/services/sudoku_victory_layout_service.dart';
import 'package:flutter_app/ui/services/sudoku_victory_overlay_service.dart';

class SudokuVictoryPositionService {
  final SudokuVictoryLayoutService _layoutService;
  final ValueNotifier<double?> centerY = ValueNotifier<double?>(null);

  SudokuVictoryPositionService(this._layoutService);

  void onOverlayStateChanged({
    required VictoryOverlayState overlayState,
    required GlobalKey overlayStackKey,
    required GlobalKey tilesPanelKey,
    required GlobalKey bottomControlsKey,
    required bool Function() isMounted,
  }) {
    if (!overlayState.visible) {
      if (centerY.value != null) {
        centerY.value = null;
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted() || !overlayState.visible) {
        return;
      }
      final next = _layoutService.midpointBetweenTilesAndBottomControls(
        overlayStackKey: overlayStackKey,
        tilesPanelKey: tilesPanelKey,
        bottomControlsKey: bottomControlsKey,
      );
      if (next == null || centerY.value == next) {
        return;
      }
      centerY.value = next;
    });
  }

  void dispose() {
    centerY.dispose();
  }
}
