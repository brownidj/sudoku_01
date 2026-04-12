import 'package:flutter/widgets.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

class SudokuControllerBindingService {
  SudokuController _controller;
  final VoidCallback _onChanged;

  SudokuControllerBindingService({
    required SudokuController controller,
    required VoidCallback onChanged,
  }) : _controller = controller,
       _onChanged = onChanged;

  void attach() {
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
  }

  void updateController(SudokuController nextController) {
    if (identical(_controller, nextController)) {
      return;
    }
    _controller.removeListener(_onChanged);
    _controller = nextController;
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
  }

  void dispose() {
    _controller.removeListener(_onChanged);
  }
}
