import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_app/ui/animal_cache_assets.dart';
import 'package:flutter_app/ui/animal_cache_catalog.dart';

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
    final instruments = await _loadDigitImages(
      AnimalCacheAssets.instrumentAssetPathForDigit,
    );
    final butterflies = await _loadDigitImages(
      AnimalCacheAssets.butterflyAssetPathForDigit,
    );
    final shells = await _loadDigitImages(
      AnimalCacheAssets.shellAssetPathForDigit,
    );
    final oldOpera = await _loadDigitImages(
      AnimalCacheAssets.operaAssetPathForDigit,
    );
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
      AnimalCacheAssets.instrumentAssetPathForDigit,
    );
    final butterflyNotes = await _loadDigitImages(
      AnimalCacheAssets.butterflyAssetPathForDigit,
    );
    final shellNotes = await _loadDigitImages(
      AnimalCacheAssets.shellAssetPathForDigit,
    );
    final oldOperaNotes = await _loadDigitImages(
      AnimalCacheAssets.operaAssetPathForDigit,
    );
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
      final name = AnimalCacheAssets.animalName(d);
      final data = await rootBundle.load(
        AnimalCacheAssets.tileAssetPath(digit: d, name: name, variant: variant),
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

  static Future<Map<int, ui.Image>> _loadNotesImages({
    required String variant,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final data = await rootBundle.load(
        AnimalCacheAssets.animalNotesAssetPath(digit: d, variant: variant),
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

  static String nameForDigit(int digit) => AnimalCacheAssets.animalName(digit);
  static String displayNameForDigit(String contentMode, int digit) =>
      AnimalCacheAssets.displayNameForDigit(contentMode, digit);

  static String displayNameForDigitTitleCase(String contentMode, int digit) =>
      AnimalCacheAssets.displayNameForDigitTitleCase(contentMode, digit);

  static String displayNameForDigitLocalizedTitleCase({
    required String contentMode,
    required int digit,
    required String languageCode,
  }) => AnimalCacheAssets.displayNameForDigitLocalizedTitleCase(
    contentMode: contentMode,
    digit: digit,
    languageCode: languageCode,
  );

  static String? butterflyDescriptionForDigit(int digit) =>
      AnimalCacheAssets.butterflyDescriptionForDigit(digit);

  static String tileAssetPathForDigit({
    required String contentMode,
    required String animalStyle,
    required int digit,
  }) => AnimalCacheAssets.tileAssetPathForDigit(
    contentMode: contentMode,
    animalStyle: animalStyle,
    digit: digit,
  );

  static String tileLabelForDigit(String contentMode, int digit) =>
      AnimalCacheAssets.tileLabelForDigit(contentMode, digit);

  static String initialForDigit(int digit) =>
      AnimalCacheAssets.initialForDigit(digit);

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
