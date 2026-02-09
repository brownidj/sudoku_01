import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class AnimalImageCache {
  static Future<Map<int, ui.Image>>? _future;

  static Future<Map<int, ui.Image>> load() {
    _future ??= _loadImages();
    return _future!;
  }

  static Future<Map<int, ui.Image>> _loadImages() async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final data = await rootBundle.load('assets/images/animals/${d}_$name.png');
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
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
        return 'ibis';
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
