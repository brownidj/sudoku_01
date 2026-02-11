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
    return {
      'simple': simple,
      'cute': cute,
    };
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>> _loadNotesAll() async {
    final sizes = [16, 20, 24, 32];
    final simple = <int, Map<int, ui.Image>>{};
    final cute = <int, Map<int, ui.Image>>{};
    for (final size in sizes) {
      simple[size] = await _loadNotesImages(variant: 'simple', size: size);
      cute[size] = await _loadNotesImages(variant: 'cute', size: size);
    }
    _notesCache = {
      'simple': simple,
      'cute': cute,
    };
    return _notesCache!;
  }

  static Future<Map<int, ui.Image>> _loadImages({required String variant}) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data = await rootBundle.load('assets/images/animals/${d}_${prefix}$name.png');
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Future<Map<int, ui.Image>> _loadNotesImages({
    required String variant,
    required int size,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data =
          await rootBundle.load('assets/images/animals/notes/$size/${d}_${prefix}$name.png');
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
        return 'camel';
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
