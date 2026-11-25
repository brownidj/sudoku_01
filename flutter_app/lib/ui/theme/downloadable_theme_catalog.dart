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
}
