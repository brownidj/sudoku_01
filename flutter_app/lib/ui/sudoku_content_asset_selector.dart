import 'dart:ui' as ui;

import 'package:flutter_app/app/ui_state.dart';

class SudokuContentAssetSelector {
  const SudokuContentAssetSelector._();

  static Map<int, ui.Image> imagesForState(
    UiState state, {
    required Map<String, Map<int, ui.Image>> imagesByVariant,
  }) {
    if (state.contentMode == 'numbers') {
      return const {};
    }
    if (state.contentMode == 'instruments') {
      return imagesByVariant['instruments'] ?? const {};
    }
    return imagesByVariant[state.animalStyle] ?? const {};
  }

  static Map<int, Map<int, ui.Image>> notesForState(
    UiState state, {
    required Map<String, Map<int, Map<int, ui.Image>>> notesByVariant,
  }) {
    if (state.contentMode == 'animals') {
      return notesByVariant[state.animalStyle] ?? const {};
    }
    if (state.contentMode == 'instruments') {
      return notesByVariant['instruments'] ?? const {};
    }
    return const {};
  }
}
