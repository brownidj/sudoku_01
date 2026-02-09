import 'package:flutter_app/app/sudoku_app.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnimalImageCache.load();
  runApp(const SudokuApp());
}
