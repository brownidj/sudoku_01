import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

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
    final simple = await _loadImages(variant: 'simple');
    final cute = await _loadImages(variant: 'cute');
    final instruments = await _loadMusicImages();
    return {'simple': simple, 'cute': cute, 'instruments': instruments};
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>>
  _loadNotesAll() async {
    final sizes = [16, 20, 24, 32];
    final simple = <int, Map<int, ui.Image>>{};
    final cute = <int, Map<int, ui.Image>>{};
    final instruments = <int, Map<int, ui.Image>>{};
    final simpleNotes = await _loadNotesImages(variant: 'simple');
    final cuteNotes = await _loadNotesImages(variant: 'cute');
    final instrumentNotes = await _loadMusicImages();
    for (final size in sizes) {
      simple[size] = Map<int, ui.Image>.from(simpleNotes);
      cute[size] = Map<int, ui.Image>.from(cuteNotes);
      instruments[size] = Map<int, ui.Image>.from(instrumentNotes);
    }
    _notesCache = {'simple': simple, 'cute': cute, 'instruments': instruments};
    return _notesCache!;
  }

  static Future<Map<int, ui.Image>> _loadImages({
    required String variant,
  }) async {
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

  static Future<Map<int, ui.Image>> _loadMusicImages() async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final data = await rootBundle.load(
        'assets/images/music/${_instrumentFileName(d)}.png',
      );
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
      return 'assets/images/animals/${digit}_cartoon_${name}_s.png';
    }
    return 'assets/images/animals/${digit}_${name}.png';
  }

  static Future<Map<int, ui.Image>> _loadNotesImages({
    required String variant,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data = await rootBundle.load(
        'assets/images/animals/${d}_${prefix}${name}_notes.png',
      );
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Map<int, ui.Image> notesFor(String variant, int size) {
    return _notesCache?[variant]?[size] ?? <int, ui.Image>{};
  }

  static String _animalName(int digit) {
    switch (digit) {
      case 1:
        return 'ape';
      case 2:
        return 'buffalo';
      case 3:
        return 'cheetah';
      case 4:
        return 'dolphin';
      case 5:
        return 'elephant';
      case 6:
        return 'frog';
      case 7:
        return 'giraffe';
      case 8:
        return 'hippo';
      case 9:
        return 'iguana';
      default:
        return 'ape';
    }
  }

  static String nameForDigit(int digit) {
    return _animalName(digit);
  }

  static String _instrumentName(int digit) {
    switch (digit) {
      case 1:
        return 'piano';
      case 2:
        return 'banjo';
      case 3:
        return 'violin';
      case 4:
        return 'trumpet';
      case 5:
        return 'horn';
      case 6:
        return 'drums';
      case 7:
        return 'saxophone';
      case 8:
        return 'tambourine';
      case 9:
        return 'ukulele';
      default:
        return 'piano';
    }
  }

  static String _instrumentFileName(int digit) {
    switch (digit) {
      case 1:
        return 'piano';
      case 2:
        return 'banjo';
      case 3:
        return 'violin';
      case 4:
        return 'trumpet';
      case 5:
        return 'horn';
      case 6:
        return 'drum';
      case 7:
        return 'saxaphone';
      case 8:
        return 'tambourine';
      case 9:
        return 'ukelele';
      default:
        return 'piano';
    }
  }

  static String displayNameForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'animals':
        return _animalName(digit);
      case 'instruments':
        return _instrumentName(digit);
      default:
        return digit.toString();
    }
  }

  static String tileLabelForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'instruments':
        final instrument = _instrumentName(digit);
        if (instrument.isEmpty) {
          return digit.toString();
        }
        return instrument[0].toUpperCase();
      default:
        return digit.toString();
    }
  }

  static String initialForDigit(int digit) {
    final name = _animalName(digit);
    if (name.isEmpty) {
      return '';
    }
    return name[0].toUpperCase();
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
