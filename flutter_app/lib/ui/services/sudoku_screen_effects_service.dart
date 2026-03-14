import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/correction_prompt_service.dart';

class SudokuScreenEffectsService {
  final CorrectionPromptService _correctionPromptService;
  int _lastCorrectionNoticeSerial = 0;

  SudokuScreenEffectsService({CorrectionPromptService? correctionPromptService})
    : _correctionPromptService =
          correctionPromptService ?? CorrectionPromptService();

  bool shouldScheduleCorrectionPrompt(Coord? promptCoord) {
    return _correctionPromptService.shouldSchedule(promptCoord);
  }

  Future<bool> showCorrectionPrompt(BuildContext context) {
    return _correctionPromptService.showPrompt(context);
  }

  bool shouldScheduleCorrectionNotice({
    required int serial,
    required String? message,
  }) {
    if (message == null || serial == 0) {
      return false;
    }
    return _lastCorrectionNoticeSerial != serial;
  }

  void showCorrectionNotice(BuildContext context, UiState state) {
    final message = state.correctionNoticeMessage;
    final serial = state.correctionNoticeSerial;
    if (!shouldScheduleCorrectionNotice(serial: serial, message: message)) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    _lastCorrectionNoticeSerial = serial;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message!)));
  }
}
