import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/sudoku_game_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SpyAnimalAssetService extends AnimalAssetService {
  int loadCalls = 0;
  bool failNextLoad = false;
  AnimalAssetBundle nextBundle = const AnimalAssetBundle(
    animalImages: {},
    noteImages: {},
  );

  @override
  Future<AnimalAssetBundle> load() async {
    loadCalls += 1;
    if (failNextLoad) {
      failNextLoad = false;
      throw Exception('asset load failed');
    }
    return nextBundle;
  }
}

Future<ui.Image> _solidImage(Color color, {int size = 8}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = color,
  );
  return recorder.endRecording().toImage(size, size);
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('does not load animal assets in numbers mode', (
    WidgetTester tester,
  ) async {
    final controller = SudokuController();
    await controller.ready;
    controller.onCellTapped(const Coord(0, 0));
    controller.onContentModeChanged('numbers');
    final service = _SpyAnimalAssetService();

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(controller: controller, animalAssetService: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.loadCalls, 0);
  });

  testWidgets('loads image assets in instruments mode', (
    WidgetTester tester,
  ) async {
    final controller = SudokuController();
    await controller.ready;
    controller.onCellTapped(const Coord(0, 0));
    controller.onContentModeChanged('instruments');
    final service = _SpyAnimalAssetService();

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(controller: controller, animalAssetService: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.loadCalls, 1);
  });

  testWidgets('loads animal assets when switching into animals mode', (
    WidgetTester tester,
  ) async {
    final controller = SudokuController();
    await controller.ready;
    controller.onCellTapped(const Coord(0, 0));
    controller.onContentModeChanged('numbers');
    final service = _SpyAnimalAssetService();

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(controller: controller, animalAssetService: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.loadCalls, 0);

    controller.onContentModeChanged('animals');
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.loadCalls, 1);
  });

  testWidgets('failed animal load can retry on later animals switch', (
    WidgetTester tester,
  ) async {
    final controller = SudokuController();
    await controller.ready;
    controller.onCellTapped(const Coord(0, 0));
    controller.onContentModeChanged('numbers');
    final service = _SpyAnimalAssetService()..failNextLoad = true;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(controller: controller, animalAssetService: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    controller.onContentModeChanged('animals');
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.loadCalls, 1);

    controller.onContentModeChanged('numbers');
    await tester.pump(const Duration(milliseconds: 100));
    controller.onContentModeChanged('animals');
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.loadCalls, 2);
  });

  testWidgets('instruments mode wires instruments images into game content', (
    WidgetTester tester,
  ) async {
    final animalImage = await _solidImage(const Color(0xFFFF0000));
    final instrumentImage = await _solidImage(const Color(0xFF00FF00));
    final controller = SudokuController();
    await controller.ready;
    controller.onCellTapped(const Coord(0, 0));
    controller.onAnimalStyleChanged('simple');
    controller.onContentModeChanged('instruments');
    final service = _SpyAnimalAssetService()
      ..nextBundle = AnimalAssetBundle(
        animalImages: {
          'simple': {1: animalImage},
          'instruments': {7: instrumentImage},
        },
        noteImages: const {},
      );

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(controller: controller, animalAssetService: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final content = tester.widget<SudokuGameContent>(
      find.byType(SudokuGameContent),
    );
    expect(content.animalImages.containsKey(7), isTrue);
    expect(content.animalImages.containsKey(1), isFalse);
  });
}
