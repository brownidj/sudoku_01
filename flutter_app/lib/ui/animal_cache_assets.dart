import 'package:flutter_app/ui/animal_cache_catalog.dart';
import 'package:flutter_app/ui/animal_cache_localized_names.dart';

class AnimalCacheAssets {
  static String animalName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.animalNames, fallback: 'ape');

  static String instrumentName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.instrumentNames, fallback: 'piano');

  static String instrumentFileName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.instrumentFileNames,
      fallback: 'piano',
    );
  }

  static String operaName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.operaNames, fallback: 'bass');

  static String operaFileName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.operaFileNames, fallback: 'bass');

  static String butterflyName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.butterflyNames,
      fallback: 'monarch',
    );
  }

  static String butterflyFileName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.butterflyFileNames,
      fallback: '1_monarch',
    );
  }

  static String shellName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.shellNames, fallback: 'cowrie');

  static String shellFileName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.shellFileNames, fallback: '1_cowrie');

  static String tileAssetPath({
    required int digit,
    required String name,
    required String variant,
  }) {
    if (variant == 'cute') {
      return 'assets/images/animals/$digit'
          '_cartoon_'
          '$name'
          '_s.png';
    }
    return 'assets/images/animals/$digit'
        '_'
        '$name'
        '.png';
  }

  static String animalNotesAssetPath({
    required int digit,
    required String variant,
  }) {
    final name = animalName(digit);
    final prefix = variant == 'cute' ? 'cartoon_' : '';
    return 'assets/images/animals/$digit'
        '_'
        '$prefix'
        '$name'
        '_notes.png';
  }

  static String displayNameForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'animals':
        return animalName(digit);
      case 'instruments':
        return instrumentName(digit);
      case 'old_opera':
        return operaName(digit);
      case 'butterflies':
        return butterflyName(digit);
      case 'shells':
        return shellName(digit);
      default:
        return digit.toString();
    }
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
    final name = animalName(digit);
    return tileAssetPath(digit: digit, name: name, variant: variant);
  }

  static String tileLabelForDigit(String contentMode, int digit) {
    final displayName = switch (contentMode) {
      'instruments' => instrumentName(digit),
      'old_opera' => operaName(digit),
      'butterflies' => butterflyName(digit),
      'shells' => shellName(digit),
      _ => '',
    };
    if (displayName.isEmpty) {
      return digit.toString();
    }
    return displayName[0].toUpperCase();
  }

  static String initialForDigit(int digit) {
    final name = animalName(digit);
    return name.isEmpty ? '' : name[0].toUpperCase();
  }

  static String instrumentAssetPathForDigit(int digit) {
    return 'assets/images/music/${instrumentFileName(digit)}.png';
  }

  static String operaAssetPathForDigit(int digit) {
    return 'assets/images/opera/${operaFileName(digit)}.png';
  }

  static String butterflyAssetPathForDigit(int digit) {
    return 'assets/images/butterflies/${butterflyFileName(digit)}.png';
  }

  static String shellAssetPathForDigit(int digit) {
    return 'assets/images/shells/${shellFileName(digit)}.png';
  }

  static String _nameAt(
    int digit,
    List<String> names, {
    required String fallback,
  }) {
    if (digit < 1 || digit > names.length) {
      return fallback;
    }
    return names[digit - 1];
  }
}
