import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const methods = MethodChannel(AppleThemePackDelivery.methodChannelName);
  const events = EventChannel(AppleThemePackDelivery.progressChannelName);
  late AppleThemePackDelivery delivery;
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    delivery = AppleThemePackDelivery(platformOverride: TargetPlatform.iOS);
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call);
      return switch (call.method) {
        'getConfiguration' => {'supported': true, 'configured': false},
        'listAssetPacks' => [
          {'id': 'marine', 'version': 7, 'downloadBytes': 12345},
        ],
        'ensureAvailable' || 'localPath' => '/native/ThemePacks/marine_v1.zip',
        _ => null,
      };
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methods, null);
  });

  test('constructing delivery never initiates a request', () {
    expect(calls, isEmpty);
  });

  test(
    'reports supported but unconfigured without starting a download',
    () async {
      final configuration = await delivery.getConfiguration();
      expect(configuration.supported, isTrue);
      expect(configuration.configured, isFalse);
      expect(calls.map((call) => call.method), ['getConfiguration']);
    },
  );

  test('Android does not call the Apple bridge', () async {
    final android = AppleThemePackDelivery(
      platformOverride: TargetPlatform.android,
    );
    expect((await android.getConfiguration()).supported, isFalse);
    expect(calls, isEmpty);
  });

  test('missing native plugin reports unavailable', () async {
    messenger.setMockMethodCallHandler(methods, null);
    final configuration = await delivery.getConfiguration();
    expect(configuration.supported, isFalse);
    expect(configuration.configured, isFalse);
  });

  test('discovery preserves Apple delivery versions and sizes', () async {
    final pack = (await delivery.listAssetPacks()).single;
    expect(pack.id, 'marine');
    expect(pack.version, 7);
    expect(pack.downloadBytes, 12345);
  });

  test(
    'request forwards the pack ID and exact namespaced relative path',
    () async {
      final path = await delivery.ensureAvailable(
        assetPackId: 'marine',
        relativePath: 'ThemePacks/marine_v1.zip',
      );
      expect(path, '/native/ThemePacks/marine_v1.zip');
      expect(calls.single.method, 'ensureAvailable');
      expect(calls.single.arguments, {
        'assetPackId': 'marine',
        'relativePath': 'ThemePacks/marine_v1.zip',
      });
    },
  );

  test('offline lookup does not request a download', () async {
    await delivery.localPath(
      assetPackId: 'marine',
      relativePath: 'ThemePacks/marine_v1.zip',
    );
    expect(calls.single.method, 'localPath');
  });

  test('rejects unsafe IDs and paths before contacting native code', () async {
    for (final path in [
      '',
      '../theme.zip',
      '/tmp/theme.zip',
      'a//b.zip',
      'a/./b.zip',
      r'a\b.zip',
      'https://host/theme.zip',
    ]) {
      await expectLater(
        delivery.ensureAvailable(assetPackId: 'marine', relativePath: path),
        throwsArgumentError,
      );
    }
    await expectLater(
      delivery.ensureAvailable(
        assetPackId: '../marine',
        relativePath: 'theme.zip',
      ),
      throwsArgumentError,
    );
    expect(calls, isEmpty);
  });

  test(
    'native setup and cancellation errors propagate to the caller',
    () async {
      for (final code in [
        'not_configured',
        'cancelled',
        'busy',
        'apple_asset_error',
      ]) {
        messenger.setMockMethodCallHandler(methods, (_) async {
          throw PlatformException(code: code);
        });
        await expectLater(
          delivery.ensureAvailable(
            assetPackId: 'marine',
            relativePath: 'theme.zip',
          ),
          throwsA(
            isA<PlatformException>().having(
              (error) => error.code,
              'code',
              code,
            ),
          ),
        );
      }
    },
  );

  test('rejects empty native file paths', () async {
    messenger.setMockMethodCallHandler(methods, (_) async => '');
    await expectLater(
      delivery.ensureAvailable(
        assetPackId: 'marine',
        relativePath: 'theme.zip',
      ),
      throwsStateError,
    );
  });

  test(
    'cancellation and delivery removal are explicit, distinct actions',
    () async {
      await delivery.cancelDownload('marine');
      await delivery.removeAssetPack('marine');
      expect(calls.map((call) => call.method), [
        'cancelDownload',
        'removeAssetPack',
      ]);
      expect(
        calls.every(
          (call) => (call.arguments as Map)['assetPackId'] == 'marine',
        ),
        isTrue,
      );
    },
  );

  test(
    'native stream decodes tagged progress without requesting a download',
    () async {
      messenger.setMockStreamHandler(
        events,
        MockStreamHandler.inline(
          onListen: (_, sink) {
            sink.success({
              'assetPackId': 'marine',
              'stage': 'downloading',
              'bytesReceived': 50,
              'totalBytes': 100,
            });
            sink.success({
              'assetPackId': 'marine',
              'stage': 'available',
              'bytesReceived': 0,
              'totalBytes': 0,
            });
            sink.endOfStream();
          },
        ),
      );
      final updates = await delivery.progress.toList();
      expect(updates.first.assetPackId, 'marine');
      expect(updates.first.fraction, 0.5);
      expect(updates.last.stage, AppleThemePackStage.available);
      expect(updates.last.fraction, isNull);
      expect(calls, isEmpty);
    },
  );
}
