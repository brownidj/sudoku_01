import 'package:flutter/services.dart';
import 'package:flutter_app/ui/theme/theme_purchase_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(ThemePurchaseGateway.channelName);
  final calls = <MethodCall>[];
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    calls.clear();
  });
  test(
    'forwards individual product IDs and Apple prices without local ownership grants',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return switch (call.method) {
              'products' => [
                {'id': 'theme_marine', 'price': 'AU\$4.99'},
              ],
              'owns' => false,
              'purchase' => 'pending',
              _ => null,
            };
          });
      const gateway = ThemePurchaseGateway();
      expect(
        (await gateway.products({'theme_marine'})).single.price,
        'AU\$4.99',
      );
      expect(await gateway.purchase('theme_marine'), 'pending');
      expect(await gateway.owns('theme_marine'), isFalse);
      await gateway.restore();
      expect(calls.map((call) => call.method), [
        'products',
        'purchase',
        'owns',
        'restore',
      ]);
      expect(calls[1].arguments, {'id': 'theme_marine'});
    },
  );
}
