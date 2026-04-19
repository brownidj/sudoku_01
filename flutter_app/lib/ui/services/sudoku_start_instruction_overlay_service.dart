import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/start_instruction_tooltip_service.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';

class SudokuStartInstructionOverlayService {
  static const String _startInstructionMessage =
      'To start, select a square you want to add an icon to.\n\n'
      'Tip: Touch and hold (long-press) labels like UNIQUE/MULTI, '
      'Hints, and Corrections to see what they do.';

  final StartInstructionTooltipService _startInstructionTooltipService;

  bool _sheetOpen = false;
  String? _lastBoardKey;

  SudokuStartInstructionOverlayService({
    StartInstructionTooltipService? startInstructionTooltipService,
  }) : _startInstructionTooltipService =
           startInstructionTooltipService ?? StartInstructionTooltipService();

  void onStateChanged({
    required BuildContext context,
    required UiState state,
    required bool Function() isMounted,
  }) {
    if (!_isEligible(state)) {
      return;
    }
    final boardKey = _boardKey(state);
    if (boardKey == _lastBoardKey || _sheetOpen) {
      return;
    }
    _lastBoardKey = boardKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) {
        return;
      }
      unawaited(_maybeShow(context: context, isMounted: isMounted));
    });
  }

  bool _isEligible(UiState state) {
    if (state.gameOver || state.selected != null) {
      return false;
    }
    for (final row in state.board.cells) {
      for (final cell in row) {
        if (cell.given) {
          continue;
        }
        if (cell.value != null || cell.notes.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  String _boardKey(UiState state) {
    final buffer = StringBuffer();
    for (final row in state.board.cells) {
      for (final cell in row) {
        buffer.write(cell.given ? '1' : '0');
        buffer.write(cell.value?.toString() ?? '_');
      }
    }
    return buffer.toString();
  }

  Future<void> _maybeShow({
    required BuildContext context,
    required bool Function() isMounted,
  }) async {
    if (_sheetOpen) {
      return;
    }
    final shouldShow = await _startInstructionTooltipService
        .consumeDisplayOpportunity();
    if (!isMounted() || !shouldShow) {
      return;
    }
    _sheetOpen = true;
    try {
      await showInfoSheet(context: context, message: _startInstructionMessage);
    } finally {
      _sheetOpen = false;
    }
  }
}
