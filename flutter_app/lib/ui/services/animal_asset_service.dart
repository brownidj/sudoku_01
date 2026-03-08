import 'dart:ui' as ui;

import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/animal_cache.dart';

class AnimalAssetBundle {
  final Map<String, Map<int, ui.Image>> animalImages;
  final Map<String, Map<int, Map<int, ui.Image>>> noteImages;

  const AnimalAssetBundle({
    required this.animalImages,
    required this.noteImages,
  });
}

class AnimalAssetService {
  const AnimalAssetService();

  Future<AnimalAssetBundle> load() async {
    final images = await AnimalImageCache.loadAll();
    Map<String, Map<int, Map<int, ui.Image>>> notes = const {};

    try {
      notes = await AnimalImageCache.loadNotesAll();
    } on Exception catch (error) {
      AppDebug.log('Failed to load note icons: $error');
      notes = const {};
    }

    return AnimalAssetBundle(animalImages: images, noteImages: notes);
  }
}
