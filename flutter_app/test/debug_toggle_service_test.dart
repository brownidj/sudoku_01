import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/services/debug_toggle_service.dart';

void main() {
  test('DebugToggleService toggles on the seventh tap within four seconds', () {
    final service = DebugToggleService();
    final start = DateTime(2026, 3, 13, 10, 0, 0);

    for (var i = 0; i < 6; i += 1) {
      expect(
        service.registerVersionTap(start.add(Duration(milliseconds: i * 300))),
        isFalse,
      );
    }

    expect(
      service.registerVersionTap(start.add(const Duration(milliseconds: 1800))),
      isTrue,
    );
  });

  test('DebugToggleService ignores taps outside the four-second window', () {
    final service = DebugToggleService();
    final start = DateTime(2026, 3, 13, 10, 0, 0);

    for (var i = 0; i < 6; i += 1) {
      service.registerVersionTap(start.add(Duration(seconds: i)));
    }

    expect(
      service.registerVersionTap(start.add(const Duration(seconds: 6))),
      isFalse,
    );
  });
}
