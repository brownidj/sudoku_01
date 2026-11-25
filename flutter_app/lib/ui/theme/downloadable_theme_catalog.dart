import 'package:flutter/foundation.dart';

/// Store product identifiers are independent of the Full Version unlock.
/// Create these as non-consumables in App Store Connect before distribution.
class DownloadableTheme {
  final String id;
  final String name;
  final String description;
  final String productId;

  const DownloadableTheme(this.id, this.name, this.description, this.productId);

  static const all = [
    DownloadableTheme(
      'marine',
      'Marine Life',
      'Nine butterfly fish, short sounds and background music.',
      String.fromEnvironment(
        'MARINE_THEME_PRODUCT_ID',
        defaultValue: 'theme_marine',
      ),
    ),
    DownloadableTheme(
      'planets',
      'Planets',
      'Explore the Solar System with nine picture tiles.',
      String.fromEnvironment(
        'PLANETS_THEME_PRODUCT_ID',
        defaultValue: 'theme_planets',
      ),
    ),
    DownloadableTheme(
      'buttons',
      'Antique Buttons',
      'Nine colourful antique button tiles.',
      String.fromEnvironment(
        'BUTTONS_THEME_PRODUCT_ID',
        defaultValue: 'theme_antique_buttons',
      ),
    ),
  ];

  static DownloadableTheme byId(String id) =>
      all.firstWhere((theme) => theme.id == id);
  static bool contains(String id) => all.any((theme) => theme.id == id);

  /// A separate local pack can be exercised without granting a store purchase.
  /// The Planets opt-in is compiled out of release builds, even if defined.
  static bool permitsDeveloperPack(String id) =>
      id == 'marine' ||
      (id == 'planets' &&
          !kReleaseMode &&
          const bool.fromEnvironment('PLANETS_DEVELOPER_PACK'));
}
