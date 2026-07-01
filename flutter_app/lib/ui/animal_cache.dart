import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_app/ui/animal_cache_catalog.dart';
import 'package:flutter_app/ui/animal_cache_localized_names.dart';

class AnimalImageCache {
  static Future<Map<String, Map<int, ui.Image>>>? _future;
  static Future<Map<String, Map<int, Map<int, ui.Image>>>>? _notesFuture;
  static Map<String, Map<int, Map<int, ui.Image>>>? _notesCache;
  static Future<Map<String, Map<int, ui.Image>>> loadAll() {
    _future ??= _loadAll().catchError((Object error, StackTrace stackTrace) {
      _future = null;
      return Future<Map<String, Map<int, ui.Image>>>.error(error, stackTrace);
    });
    return _future!;
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>> loadNotesAll() {
    _notesFuture ??= _loadNotesAll().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _notesFuture = null;
      return Future<Map<String, Map<int, Map<int, ui.Image>>>>.error(
        error,
        stackTrace,
      );
    });
    return _notesFuture!;
  }

  static Future<Map<int, ui.Image>> loadVariant(String variant) async {
    final all = await loadAll();
    return all[variant] ?? all['simple'] ?? <int, ui.Image>{};
  }

  static Future<Map<String, Map<int, ui.Image>>> _loadAll() async {
    final simple = await _loadAnimalImagesForVariant('simple');
    final cute = await _loadAnimalImagesForVariant('cute');
    final instruments = await _loadDigitImages(_instrumentAssetPathForDigit);
    final butterflies = await _loadDigitImages(_butterflyAssetPathForDigit);
    final shells = await _loadDigitImages(_shellAssetPathForDigit);
    final oldOpera = await _loadDigitImages(_operaAssetPathForDigit);
    return {
      'simple': simple,
      'cute': cute,
      'instruments': instruments,
      'butterflies': butterflies,
      'shells': shells,
      'old_opera': oldOpera,
    };
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>>
  _loadNotesAll() async {
    final simple = <int, Map<int, ui.Image>>{};
    final cute = <int, Map<int, ui.Image>>{};
    final instruments = <int, Map<int, ui.Image>>{};
    final butterflies = <int, Map<int, ui.Image>>{};
    final shells = <int, Map<int, ui.Image>>{};
    final oldOpera = <int, Map<int, ui.Image>>{};
    final simpleNotes = await _loadAnimalNotesForVariant('simple');
    final cuteNotes = await _loadAnimalNotesForVariant('cute');
    final instrumentNotes = await _loadDigitImages(
      _instrumentAssetPathForDigit,
    );
    final butterflyNotes = await _loadDigitImages(_butterflyAssetPathForDigit);
    final shellNotes = await _loadDigitImages(_shellAssetPathForDigit);
    final oldOperaNotes = await _loadDigitImages(_operaAssetPathForDigit);
    for (final size in AnimalCacheCatalog.noteSizes) {
      simple[size] = Map<int, ui.Image>.from(simpleNotes);
      cute[size] = Map<int, ui.Image>.from(cuteNotes);
      instruments[size] = Map<int, ui.Image>.from(instrumentNotes);
      butterflies[size] = Map<int, ui.Image>.from(butterflyNotes);
      shells[size] = Map<int, ui.Image>.from(shellNotes);
      oldOpera[size] = Map<int, ui.Image>.from(oldOperaNotes);
    }
    _notesCache = {
      'simple': simple,
      'cute': cute,
      'instruments': instruments,
      'butterflies': butterflies,
      'shells': shells,
      'old_opera': oldOpera,
    };
    return _notesCache!;
  }

  static Future<Map<int, ui.Image>> _loadAnimalImagesForVariant(
    String variant,
  ) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final data = await rootBundle.load(
        _tileAssetPath(digit: d, name: name, variant: variant),
      );
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Future<Map<int, ui.Image>> _loadDigitImages(
    String Function(int digit) pathForDigit,
  ) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final data = await rootBundle.load(pathForDigit(d));
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static String _tileAssetPath({
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

  static Future<Map<int, ui.Image>> _loadNotesImages({
    required String variant,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data = await rootBundle.load(
        'assets/images/animals/$d'
        '_'
        '$prefix'
        '$name'
        '_notes.png',
      );
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Future<Map<int, ui.Image>> _loadAnimalNotesForVariant(
    String variant,
  ) => _loadNotesImages(variant: variant);
  static Map<int, ui.Image> notesFor(String variant, int size) {
    return _notesCache?[variant]?[size] ?? <int, ui.Image>{};
  }

  static String _animalName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.animalNames, fallback: 'ape');
  static String nameForDigit(int digit) => _animalName(digit);
  static String _instrumentName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.instrumentNames, fallback: 'piano');
  static String _instrumentFileName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.instrumentFileNames,
      fallback: 'piano',
    );
  }

  static String _operaName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.operaNames, fallback: 'bass');
  static String _operaFileName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.operaFileNames, fallback: 'bass');
  static String _butterflyName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.butterflyNames,
      fallback: 'monarch',
    );
  }

  static String _butterflyFileName(int digit) {
    return _nameAt(
      digit,
      AnimalCacheCatalog.butterflyFileNames,
      fallback: '1_monarch',
    );
  }

  static String _shellName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.shellNames, fallback: 'cowrie');
  static String _shellFileName(int digit) =>
      _nameAt(digit, AnimalCacheCatalog.shellFileNames, fallback: '1_cowrie');
  static String displayNameForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'animals':
        return _animalName(digit);
      case 'instruments':
        return _instrumentName(digit);
      case 'old_opera':
        return _operaName(digit);
      case 'butterflies':
        return _butterflyName(digit);
      case 'shells':
        return _shellName(digit);
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
      return _instrumentAssetPathForDigit(digit);
    }
    if (contentMode == 'old_opera') {
      return _operaAssetPathForDigit(digit);
    }
    if (contentMode == 'butterflies') {
      return _butterflyAssetPathForDigit(digit);
    }
    if (contentMode == 'shells') {
      return _shellAssetPathForDigit(digit);
    }
    final variant = AnimalCacheCatalog.variants.contains(animalStyle)
        ? animalStyle
        : 'simple';
    final name = _animalName(digit);
    return _tileAssetPath(digit: digit, name: name, variant: variant);
  }

  static String tileLabelForDigit(String contentMode, int digit) {
    final displayName = switch (contentMode) {
      'instruments' => _instrumentName(digit),
      'old_opera' => _operaName(digit),
      'butterflies' => _butterflyName(digit),
      'shells' => _shellName(digit),
      _ => '',
    };
    if (displayName.isEmpty) {
      return digit.toString();
    }
    return displayName[0].toUpperCase();
  }

  static String initialForDigit(int digit) {
    final name = _animalName(digit);
    return name.isEmpty ? '' : name[0].toUpperCase();
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

  static String _instrumentAssetPathForDigit(int digit) {
    return 'assets/images/music/${_instrumentFileName(digit)}.png';
  }

  static String _operaAssetPathForDigit(int digit) {
    return 'assets/images/opera/${_operaFileName(digit)}.png';
  }

  static String _butterflyAssetPathForDigit(int digit) {
    return 'assets/images/butterflies/${_butterflyFileName(digit)}.png';
  }

  static String _shellAssetPathForDigit(int digit) {
    return 'assets/images/shells/${_shellFileName(digit)}.png';
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
