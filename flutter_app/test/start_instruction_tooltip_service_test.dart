import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/services/start_instruction_tooltip_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shows at most twice for a single app version/build', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = StartInstructionTooltipService(
      versionKeyLoader: () async => 'ZuDoKu 1.2.3 build 456',
    );

    expect(await service.consumeDisplayOpportunity(), isTrue);
    expect(await service.consumeDisplayOpportunity(), isTrue);
    expect(await service.consumeDisplayOpportunity(), isFalse);
  });

  test('resets display count when app version/build changes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final serviceV1 = StartInstructionTooltipService(
      versionKeyLoader: () async => 'ZuDoKu 1.2.3 build 456',
    );

    expect(await serviceV1.consumeDisplayOpportunity(), isTrue);
    expect(await serviceV1.consumeDisplayOpportunity(), isTrue);
    expect(await serviceV1.consumeDisplayOpportunity(), isFalse);

    final serviceV2 = StartInstructionTooltipService(
      versionKeyLoader: () async => 'ZuDoKu 1.2.4 build 457',
    );

    expect(await serviceV2.consumeDisplayOpportunity(), isTrue);
    expect(await serviceV2.consumeDisplayOpportunity(), isTrue);
    expect(await serviceV2.consumeDisplayOpportunity(), isFalse);
  });
}
