import 'package:flutter_app/ui/theme/bundled_theme_factory.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_repository.dart';

class UnknownThemeException implements Exception {
  final String themeId;

  const UnknownThemeException(this.themeId);

  @override
  String toString() => 'UnknownThemeException: $themeId';
}

class BundledThemeRepository implements ThemeRepository {
  static const freeThemeIds = <String>{'animals', 'instruments', 'numbers'};

  static const premiumThemeIds = <String>{'butterflies', 'shells', 'old_opera'};

  static const themeIds = <String>[
    'animals',
    'instruments',
    'butterflies',
    'shells',
    'old_opera',
    'numbers',
  ];

  static final Map<String, ThemeDefinition> _definitions =
      BundledThemeFactory.buildDefinitions();

  const BundledThemeRepository();

  @override
  Future<List<ThemeSummary>> getAvailableThemes() async => summaries;

  @override
  Future<ThemeDefinition> loadTheme(String themeId) async =>
      themeDefinitionFor(themeId);

  @override
  Future<bool> isInstalled(String themeId) async => hasTheme(themeId);

  @override
  Future<void> installTheme(String themeId) async {
    if (!hasTheme(themeId)) {
      throw UnknownThemeException(themeId);
    }
  }

  @override
  Future<void> removeTheme(String themeId) async {
    if (!hasTheme(themeId)) {
      throw UnknownThemeException(themeId);
    }
    throw UnsupportedError('Bundled themes cannot be removed.');
  }

  @override
  Stream<List<ThemeSummary>> watchThemes() => Stream.value(summaries);

  static bool hasTheme(String themeId) =>
      _definitions.containsKey(_normalizeThemeId(themeId));

  static List<ThemeSummary> get summaries => themeIds
      .map((themeId) => _summaryFor(themeDefinitionFor(themeId)))
      .toList(growable: false);

  static ThemeDefinition themeDefinitionFor(String themeId) {
    final normalized = _normalizeThemeId(themeId);
    final definition = _definitions[normalized];
    if (definition == null) {
      throw UnknownThemeException(themeId);
    }
    return definition;
  }

  static String? tileImagePath({
    required String themeId,
    required int digit,
    String? variant,
  }) => _tileForDigit(themeId, digit)?.imagePathForVariant(variant);

  static String? tileNoteImagePath({
    required String themeId,
    required int digit,
    String? variant,
  }) => _tileForDigit(themeId, digit)?.noteImagePathForVariant(variant);

  static String displayNameForDigit(String themeId, int digit) {
    return _tileForDigit(themeId, digit)?.displayName ?? digit.toString();
  }

  static String tileLabelForDigit(String themeId, int digit) {
    return _tileForDigit(themeId, digit)?.label ?? digit.toString();
  }

  static String? tilePreviewAudioAsset({
    required String themeId,
    required int digit,
  }) {
    final definition = _definitions[_normalizeThemeId(themeId)];
    return definition?.audio?.tilePreviewAssetForDigit(digit);
  }

  static List<String> celebrationImagePathsForTheme(String themeId) {
    final normalized = _normalizeThemeId(themeId);
    if (normalized == 'numbers') {
      return _nonNumberThemes()
          .expand(_celebrationImagePathsForDefinition)
          .toList(growable: false);
    }
    final definition = _definitions[normalized];
    if (definition == null) {
      return const <String>[];
    }
    return _celebrationImagePathsForDefinition(definition);
  }

  static String? celebrationAudioAssetForImagePath(String? imagePath) {
    if (imagePath == null) {
      return null;
    }
    final normalizedPath = imagePath.toLowerCase().replaceAll('\\', '/');
    for (final definition in _nonNumberThemes()) {
      for (var digit = 1; digit <= definition.tiles.length; digit += 1) {
        final tile = definition.tileForDigit(digit);
        final celebrationPath = tile?.celebrationImagePath;
        if (celebrationPath == null) {
          continue;
        }
        if (celebrationPath.toLowerCase().replaceAll('\\', '/') ==
            normalizedPath) {
          return definition.audio?.tileCelebrationAssetForDigit(digit);
        }
      }
    }
    return null;
  }

  static ThemeTile? _tileForDigit(String themeId, int digit) {
    if (digit < 1 || digit > 9) {
      return null;
    }
    final definition = _definitions[_normalizeThemeId(themeId)];
    return definition?.tileForDigit(digit);
  }

  static ThemeSummary _summaryFor(ThemeDefinition definition) {
    return ThemeSummary(
      id: definition.id,
      displayName: definition.displayName,
      description: _descriptionFor(definition.id),
      previewImage: _previewImageFor(definition.id),
      source: ThemeSource.bundled,
      isInstalled: true,
      isOwned: true,
      hasUpdate: false,
      version: definition.version,
    );
  }

  static String _normalizeThemeId(String themeId) =>
      themeId.trim().toLowerCase();

  static String _descriptionFor(String themeId) {
    return switch (themeId) {
      'animals' => 'Starter animal tile theme.',
      'instruments' => 'Starter music tile theme.',
      'butterflies' => 'Premium butterfly tile theme.',
      'shells' => 'Premium shell tile theme.',
      'old_opera' => 'Premium opera tile theme.',
      'numbers' => 'Classic number tile theme.',
      _ => '',
    };
  }

  static String _previewImageFor(String themeId) {
    final firstTile = themeDefinitionFor(themeId).tileForDigit(1);
    return firstTile?.imagePath ?? '';
  }

  static Iterable<ThemeDefinition> _nonNumberThemes() {
    return themeIds
        .where((themeId) => themeId != 'numbers')
        .map(themeDefinitionFor);
  }

  static List<String> _celebrationImagePathsForDefinition(
    ThemeDefinition definition,
  ) {
    return definition.tiles
        .map((tile) => tile.celebrationImagePath)
        .whereType<String>()
        .toList(growable: false);
  }
}
