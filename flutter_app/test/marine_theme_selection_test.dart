import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'free Marine Life selection preserves the puzzle and survives restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      const policy = PremiumPolicyService();
      expect(policy.isContentModeUnlocked('marine', Entitlement.free), isTrue);
      expect(policy.isBackgroundMusicThemeMode('marine'), isFalse);

      final controller = SudokuController();
      await controller.ready;
      final values = controller.state.board.cells
          .map((row) => row.map((cell) => cell.value).toList())
          .toList();
      controller.onContentModeChanged('marine');
      expect(controller.state.contentMode, 'marine');
      expect(
        controller.state.board.cells
            .map((row) => row.map((cell) => cell.value).toList())
            .toList(),
        values,
      );
      await controller.flushGameSession();
      controller.dispose();

      final restored = SudokuController();
      await restored.ready;
      expect(restored.state.contentMode, 'marine');
      restored.dispose();
    },
  );
}
