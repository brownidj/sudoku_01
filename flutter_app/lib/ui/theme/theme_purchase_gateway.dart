import 'package:flutter/services.dart';

class ThemeStoreProduct {
  final String id;
  final String price;
  const ThemeStoreProduct(this.id, this.price);
}

/// StoreKit 2 verifies signed transactions on iOS. A local preference or the
/// presence of downloaded files never grants permission to download a paid pack.
class ThemePurchaseGateway {
  static const channelName = 'org.topository.animalsudoku/theme_purchases';
  final MethodChannel channel;
  const ThemePurchaseGateway({this.channel = const MethodChannel(channelName)});

  Stream<void> get changes => const EventChannel(
    '$channelName/updates',
  ).receiveBroadcastStream().map((_) {});

  Future<List<ThemeStoreProduct>> products(Set<String> ids) async {
    final values = await channel.invokeListMethod<Object?>('products', {
      'ids': ids.toList(),
    });
    return [
      for (final value in values ?? [])
        ThemeStoreProduct(
          (value as Map)['id'] as String,
          value['price'] as String,
        ),
    ];
  }

  Future<bool> owns(String productId) async =>
      await channel.invokeMethod<bool>('owns', {'id': productId}) == true;

  /// Returns purchased, cancelled, or pending. Ownership is rechecked separately.
  Future<String> purchase(String productId) async =>
      await channel.invokeMethod<String>('purchase', {'id': productId}) ??
      'cancelled';

  Future<void> restore() => channel.invokeMethod<void>('restore');
}
