import 'package:flutter_app/ui/animal_cache_catalog.dart';
import 'package:flutter_app/ui/animal_cache_localized_names.dart';
import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';

class AnimalCacheAssets {
  static String animalName(int digit) =>
      BundledThemeRepository.displayNameForDigit('animals', digit);

  static String instrumentName(int digit) =>
      BundledThemeRepository.displayNameForDigit('instruments', digit);

  static String instrumentFileName(int digit) {
    return BundledThemeRepository.themeDefinitionFor(
          'instruments',
        ).tileForDigit(digit)?.id ??
        'piano';
  }

  static String operaName(int digit) =>
      BundledThemeRepository.displayNameForDigit('old_opera', digit);

  static String operaFileName(int digit) =>
      BundledThemeRepository.themeDefinitionFor(
        'old_opera',
      ).tileForDigit(digit)?.id ??
      'bass';

  static String butterflyName(int digit) {
    return BundledThemeRepository.displayNameForDigit('butterflies', digit);
  }

  static String butterflyFileName(int digit) {
    return BundledThemeRepository.themeDefinitionFor(
          'butterflies',
        ).tileForDigit(digit)?.id ??
        '1_monarch';
  }

  static String shellName(int digit) =>
      BundledThemeRepository.displayNameForDigit('shells', digit);

  static String shellFileName(int digit) =>
      BundledThemeRepository.themeDefinitionFor(
        'shells',
      ).tileForDigit(digit)?.id ??
      '1_cowrie';

  static String tileAssetPath({
    required int digit,
    required String name,
    required String variant,
  }) {
    return BundledThemeRepository.tileImagePath(
          themeId: 'animals',
          digit: digit,
          variant: variant,
        ) ??
        '';
  }

  static String animalNotesAssetPath({
    required int digit,
    required String variant,
  }) {
    return BundledThemeRepository.tileNoteImagePath(
          themeId: 'animals',
          digit: digit,
          variant: variant,
        ) ??
        '';
  }

  static String displayNameForDigit(String contentMode, int digit) {
    return BundledThemeRepository.displayNameForDigit(contentMode, digit);
  }

  static String displayNameForDigitTitleCase(String contentMode, int digit) {
    final raw = displayNameForDigit(contentMode, digit).trim();
    if (raw.isEmpty) {
      return raw;
    }
    return raw
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String displayNameForDigitLocalizedTitleCase({
    required String contentMode,
    required int digit,
    required String languageCode,
  }) {
    final localized =
        animalCacheLocalizedDisplayNames[languageCode]?[contentMode];
    if (localized != null && digit >= 1 && digit <= localized.length) {
      return localized[digit - 1];
    }
    return displayNameForDigitTitleCase(contentMode, digit);
  }

  static String? butterflyDescriptionForDigit(int digit) {
    if (digit < 1 || digit > AnimalCacheCatalog.butterflyDescriptions.length) {
      return null;
    }
    return AnimalCacheCatalog.butterflyDescriptions[digit - 1];
  }

  static String tileAssetPathForDigit({
    required String contentMode,
    required String animalStyle,
    required int digit,
  }) {
    if (contentMode == 'instruments') {
      return instrumentAssetPathForDigit(digit);
    }
    if (contentMode == 'old_opera') {
      return operaAssetPathForDigit(digit);
    }
    if (contentMode == 'butterflies') {
      return butterflyAssetPathForDigit(digit);
    }
    if (contentMode == 'shells') {
      return shellAssetPathForDigit(digit);
    }
    final variant = AnimalCacheCatalog.variants.contains(animalStyle)
        ? animalStyle
        : 'simple';
    return BundledThemeRepository.tileImagePath(
          themeId: contentMode,
          digit: digit,
          variant: variant,
        ) ??
        '';
  }

  static String tileLabelForDigit(String contentMode, int digit) {
    return BundledThemeRepository.tileLabelForDigit(contentMode, digit);
  }

  static String initialForDigit(int digit) {
    final name = animalName(digit);
    return name.isEmpty ? '' : name[0].toUpperCase();
  }

  static String instrumentAssetPathForDigit(int digit) {
    return BundledThemeRepository.tileImagePath(
          themeId: 'instruments',
          digit: digit,
        ) ??
        '';
  }

  static String operaAssetPathForDigit(int digit) {
    return BundledThemeRepository.tileImagePath(
          themeId: 'old_opera',
          digit: digit,
        ) ??
        '';
  }

  static String butterflyAssetPathForDigit(int digit) {
    return BundledThemeRepository.tileImagePath(
          themeId: 'butterflies',
          digit: digit,
        ) ??
        '';
  }

  static String shellAssetPathForDigit(int digit) {
    return BundledThemeRepository.tileImagePath(
          themeId: 'shells',
          digit: digit,
        ) ??
        '';
  }
}
