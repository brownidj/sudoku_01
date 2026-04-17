import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class AnimalImageCache {
  static Future<Map<String, Map<int, ui.Image>>>? _future;
  static Future<Map<String, Map<int, Map<int, ui.Image>>>>? _notesFuture;
  static Map<String, Map<int, Map<int, ui.Image>>>? _notesCache;

  static Future<Map<String, Map<int, ui.Image>>> loadAll() {
    _future ??= _loadAll();
    return _future!;
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>> loadNotesAll() {
    _notesFuture ??= _loadNotesAll();
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

  static String _instrumentFileName(int digit) {
    switch (digit) {
      case 1:
        return 'maracas';
      case 2:
        return 'drum';
      case 3:
        return 'horn';
      case 4:
        return 'piano';
      case 5:
        return 'saxaphone';
      case 6:
        return 'tambourine';
      case 7:
        return 'trumpet';
      case 8:
        return 'ukelele';
      case 9:
        return 'violin';
      default:
        return 'maracas';
    }
  }

  static String _instrumentDisplayName(int digit) {
    switch (digit) {
      case 1:
        return 'maracas';
      case 2:
        return 'hand drum';
      case 3:
        return 'French horn';
      case 4:
        return 'grand piano';
      case 5:
        return 'saxophone';
      case 6:
        return 'tambourine';
      case 7:
        return 'trumpet';
      case 8:
        return 'ukulele';
      case 9:
        return 'violin';
      default:
        return 'maracas';
    }
  }

  static String nameForDigit(int digit) {
    return _animalName(digit);
  }

  static String displayNameForDigit(String contentMode, int digit) {
    if (contentMode == 'instruments') {
      return _instrumentDisplayName(digit);
    }
    return _animalName(digit);
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
