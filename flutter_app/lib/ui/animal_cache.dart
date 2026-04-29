import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class AnimalImageCache {
  static const List<String> _animalNames = <String>[
    'ape',
    'buffalo',
    'cheetah',
    'dolphin',
    'elephant',
    'frog',
    'giraffe',
    'hippo',
    'iguana',
  ];
  static const List<String> _instrumentNames = <String>[
    'piano',
    'banjo',
    'violin',
    'trumpet',
    'horn',
    'drums',
    'saxophone',
    'tambourine',
    'ukulele',
  ];
  static const List<String> _instrumentFileNames = <String>[
    'piano',
    'banjo',
    'violin',
    'trumpet',
    'horn',
    'drum',
    'saxaphone',
    'tambourine',
    'ukelele',
  ];
  static const List<String> _operaNames = <String>[
    'bass',
    'baritone',
    'tenor',
    'mezzo soprano',
    'soprano',
    'royal court singer',
    'modern opera performer',
    'masked phantom style',
    'opera diva comic',
  ];
  static const List<String> _operaFileNames = <String>[
    'bass',
    'baritone',
    'tenor',
    'mezzo_soprano',
    'soprano',
    'royal_court_singer',
    'modern_opera',
    'masked_phantom_style',
    'opera_diva_comic',
  ];

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
    final oldOpera = await _loadOperaImages();
    return {
      'simple': simple,
      'cute': cute,
      'instruments': instruments,
      'old_opera': oldOpera,
    };
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>>
  _loadNotesAll() async {
    final sizes = [16, 20, 24, 32];
    final simple = <int, Map<int, ui.Image>>{};
    final cute = <int, Map<int, ui.Image>>{};
    final instruments = <int, Map<int, ui.Image>>{};
    final oldOpera = <int, Map<int, ui.Image>>{};
    final simpleNotes = await _loadNotesImages(variant: 'simple');
    final cuteNotes = await _loadNotesImages(variant: 'cute');
    final instrumentNotes = await _loadMusicImages();
    final oldOperaNotes = await _loadOperaImages();
    for (final size in sizes) {
      simple[size] = Map<int, ui.Image>.from(simpleNotes);
      cute[size] = Map<int, ui.Image>.from(cuteNotes);
      instruments[size] = Map<int, ui.Image>.from(instrumentNotes);
      oldOpera[size] = Map<int, ui.Image>.from(oldOperaNotes);
    }
    _notesCache = {
      'simple': simple,
      'cute': cute,
      'instruments': instruments,
      'old_opera': oldOpera,
    };
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

  static Future<Map<int, ui.Image>> _loadOperaImages() async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final data = await rootBundle.load(
        'assets/images/opera/${_operaFileName(d)}.png',
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
    return _nameAt(digit, _animalNames, fallback: 'ape');
  }

  static String nameForDigit(int digit) {
    return _animalName(digit);
  }

  static String _instrumentName(int digit) {
    return _nameAt(digit, _instrumentNames, fallback: 'piano');
  }

  static String _instrumentFileName(int digit) {
    return _nameAt(digit, _instrumentFileNames, fallback: 'piano');
  }

  static String _operaName(int digit) {
    return _nameAt(digit, _operaNames, fallback: 'bass');
  }

  static String _operaFileName(int digit) {
    return _nameAt(digit, _operaFileNames, fallback: 'bass');
  }

  static String displayNameForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'animals':
        return _animalName(digit);
      case 'instruments':
        return _instrumentName(digit);
      case 'old_opera':
        return _operaName(digit);
      default:
        return digit.toString();
    }
  }

  static String tileAssetPathForDigit({
    required String contentMode,
    required String animalStyle,
    required int digit,
  }) {
    if (contentMode == 'instruments') {
      return 'assets/images/music/${_instrumentFileName(digit)}.png';
    }
    if (contentMode == 'old_opera') {
      return 'assets/images/opera/${_operaFileName(digit)}.png';
    }
    final variant = animalStyle == 'cute' ? 'cute' : 'simple';
    final name = _animalName(digit);
    return _tileAssetPath(digit: digit, name: name, variant: variant);
  }

  static String tileLabelForDigit(String contentMode, int digit) {
    switch (contentMode) {
      case 'instruments':
        final instrument = _instrumentName(digit);
        if (instrument.isEmpty) {
          return digit.toString();
        }
        return instrument[0].toUpperCase();
      case 'old_opera':
        final singer = _operaName(digit);
        if (singer.isEmpty) {
          return digit.toString();
        }
        return singer[0].toUpperCase();
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

  static String _nameAt(int digit, List<String> names, {required String fallback}) {
    if (digit < 1 || digit > names.length) {
      return fallback;
    }
    return names[digit - 1];
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
