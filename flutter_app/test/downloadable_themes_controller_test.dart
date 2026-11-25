import 'dart:async';

import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downloadable_themes_test_support.dart';

void main() {
  late ThemeStoreFixture fixture;
  setUp(() => fixture = ThemeStoreFixture());
  tearDown(() => fixture.dispose());

  test(
    'validated Marine Life developer pack is usable without store or purchase',
    () async {
      final pilot = fixture.pilots['marine']!..developerPack = true;
      pilot.installed = pilot.definition;
      pilot.published = false;
      fixture.purchases.storeAvailable = false;
      await fixture.controller.initialize();
      expect(fixture.controller.canUse('marine'), isTrue);
      expect(fixture.controller.themes['marine']!.owned, isFalse);
      expect(fixture.controller.canDownload('marine'), isFalse);
      expect(fixture.purchases.bought, isEmpty);
      fixture.controller.busy = true;
      expect(fixture.controller.canUse('marine'), isFalse);
      fixture.controller.busy = false;
      pilot.damaged = true;
      await fixture.controller.refresh();
      expect(fixture.controller.canUse('marine'), isFalse);
    },
  );

  test(
    'paid installed themes require their own purchase, including after revocation',
    () async {
      for (final pilot in fixture.pilots.values) {
        pilot.installed = pilot.definition;
      }
      fixture.purchases.owned.add('premium_unlock');
      await fixture.controller.initialize();
      for (final id in ['marine', 'planets', 'buttons']) {
        expect(fixture.controller.canUse(id), isFalse);
        final productId = fixture.pilots[id]!.definition.productId!;
        fixture.purchases.owned.add(productId);
        await fixture.controller.refreshOwnership();
        expect(fixture.controller.canUse(id), isTrue);
        fixture.purchases.owned.remove(productId);
        await fixture.controller.refreshOwnership();
        expect(fixture.controller.canUse(id), isFalse);
      }
    },
  );

  test('free developer exception does not extend to other themes', () async {
    for (final id in ['planets', 'buttons']) {
      final pilot = fixture.pilots[id]!..developerPack = true;
      pilot.installed = pilot.definition;
    }
    await fixture.controller.initialize();
    expect(fixture.controller.canUse('planets'), isFalse);
    expect(fixture.controller.canUse('buttons'), isFalse);
    expect(fixture.controller.canUse('marine'), isFalse);
  });

  test(
    'owning the expected product cannot unlock a pack bound to another product',
    () async {
      fixture.pilots['marine']!.installed = const ThemeDefinition(
        id: 'marine',
        productId: 'theme_planets',
        displayName: 'Marine Life',
        tiles: [],
        audio: null,
        colours: ThemeColours(),
        typography: null,
        version: 4,
      );
      fixture.purchases.owned.add('theme_marine');
      await fixture.controller.initialize();
      expect(fixture.controller.canUse('marine'), isFalse);
    },
  );

  test(
    'corrupt installed files can be removed before a purchased redownload',
    () async {
      fixture.purchases.owned.add('theme_marine');
      fixture.pilots['marine']!.damaged = true;
      await fixture.controller.initialize();
      expect(fixture.controller.themes['marine']!.damagedInstallation, isTrue);
      expect(fixture.controller.canDownload('marine'), isFalse);
      await fixture.controller.remove('marine');
      expect(fixture.controller.canDownload('marine'), isTrue);
      await fixture.controller.download('marine');
      expect(fixture.controller.themes['marine']!.installed, isNotNull);
    },
  );

  test('a deferred purchase arriving during a download is not lost', () async {
    await fixture.controller.initialize();
    await fixture.controller.buy('marine');
    final pilot = fixture.pilots['marine']!
      ..pending = Completer<ThemeDefinition>();
    final download = fixture.controller.download('marine');
    await Future<void>.delayed(Duration.zero);
    fixture.purchases.owned.add('theme_planets');
    fixture.purchases.events.add(null);
    pilot.pending!.complete(pilot.definition);
    await download;
    expect(fixture.controller.themes['planets']!.owned, isTrue);
    expect(fixture.controller.canDownload('planets'), isTrue);
  });

  test(
    'purchases are separate and a cancelled or pending purchase never unlocks downloads',
    () async {
      await fixture.controller.initialize();
      expect(fixture.controller.canDownload('marine'), isFalse);
      for (final outcome in ['cancelled', 'pending']) {
        fixture.purchases.outcome = outcome;
        await fixture.controller.buy('marine');
        expect(fixture.controller.canDownload('marine'), isFalse);
        expect(fixture.pilots['marine']!.downloads, 0);
      }
      fixture.purchases.outcome = 'purchased';
      await fixture.controller.buy('marine');
      expect(fixture.controller.canDownload('marine'), isTrue);
      expect(fixture.controller.canDownload('planets'), isFalse);
      expect(fixture.controller.canDownload('buttons'), isFalse);
      expect(fixture.purchases.owned, {'theme_marine'});
    },
  );

  test(
    'download failure retains purchase and retry does not charge again',
    () async {
      await fixture.controller.initialize();
      await fixture.controller.buy('marine');
      fixture.pilots['marine']!.failDownload = true;
      await fixture.controller.download('marine');
      expect(fixture.controller.themes['marine']!.owned, isTrue);
      expect(fixture.controller.themes['marine']!.error, isNotNull);
      fixture.pilots['marine']!.failDownload = false;
      await fixture.controller.download('marine');
      expect(fixture.controller.themes['marine']!.installed?.id, 'marine');
      expect(fixture.purchases.bought, ['theme_marine']);
      await fixture.controller.remove('marine');
      expect(fixture.controller.themes['marine']!.installed, isNull);
      expect(fixture.controller.canDownload('marine'), isTrue);
    },
  );

  test(
    'restore and deferred transaction events recheck each product entitlement',
    () async {
      await fixture.controller.initialize();
      fixture.purchases.owned.add('theme_planets');
      await fixture.controller.restore();
      expect(fixture.purchases.restores, 1);
      expect(fixture.controller.themes['planets']!.owned, isTrue);
      expect(fixture.controller.themes['marine']!.owned, isFalse);
      fixture.purchases.owned.add('theme_marine');
      fixture.purchases.events.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(fixture.controller.themes['marine']!.owned, isTrue);
      fixture.purchases.owned.remove('theme_marine');
      await fixture.controller.download('marine');
      expect(fixture.pilots['marine']!.downloads, 0);
      expect(fixture.controller.themes['marine']!.owned, isFalse);
    },
  );

  test(
    'unpublished content and missing store products cannot be purchased',
    () async {
      fixture.pilots['planets']!.published = false;
      await fixture.controller.initialize();
      expect(fixture.controller.canBuy('planets'), isFalse);
      await fixture.controller.buy('planets');
      expect(fixture.purchases.bought, isEmpty);
      fixture.purchases.storeAvailable = false;
      await fixture.controller.refresh();
      expect(fixture.controller.canBuy('marine'), isFalse);
    },
  );

  test(
    'pending download disables duplicate requests and cancellation permits retry',
    () async {
      await fixture.controller.initialize();
      await fixture.controller.buy('marine');
      final pilot = fixture.pilots['marine']!
        ..pending = Completer<ThemeDefinition>();
      final download = fixture.controller.download('marine');
      await Future<void>.delayed(Duration.zero);
      await fixture.controller.download('marine');
      expect(pilot.downloads, 1);
      expect(fixture.controller.busy, isTrue);
      await fixture.controller.cancel();
      await download;
      expect(pilot.cancels, 1);
      expect(fixture.controller.busy, isFalse);
      expect(fixture.controller.canDownload('marine'), isTrue);
      expect(fixture.controller.status, 'Download cancelled.');
    },
  );

  test(
    'unsupported devices retain installed files without offering purchases',
    () async {
      fixture.native.supported = false;
      fixture.pilots['marine']!.installed =
          fixture.pilots['marine']!.definition;
      await fixture.controller.initialize();
      expect(fixture.controller.themes['marine']!.installed, isNotNull);
      expect(fixture.controller.canBuy('marine'), isFalse);
      expect(fixture.controller.canDownload('marine'), isFalse);
    },
  );
}
