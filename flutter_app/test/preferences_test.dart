import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('controller loads persisted preferences', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'animal_style': 'simple',
      'content_mode': 'numbers',
      'style_name': 'Classic',
      'difficulty': 'hard',
    });

    final controller = SudokuController();
    await Future<void>.delayed(Duration.zero);

    final state = controller.state;
    expect(state.animalStyle, 'simple');
    expect(state.contentMode, 'numbers');
    expect(state.styleName, 'Classic');
    expect(state.difficulty, 'hard');
  });

  test('controller keeps persisted instruments content mode', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'content_mode': 'instruments',
    });

    final controller = SudokuController();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.contentMode, 'instruments');
  });

  test('controller restores persisted very_hard difficulty', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'difficulty': 'very_hard',
    });

    final controller = SudokuController();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.difficulty, 'very_hard');
  });
}
