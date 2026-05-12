import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/launch_screen.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sudoku_controller_test_support.dart';

class DelayedAnimalAssetService extends AnimalAssetService {
  final Completer<AnimalAssetBundle> _completer = Completer<AnimalAssetBundle>();
  int loadCalls = 0;
  @override
  Future<AnimalAssetBundle> load() {
    loadCalls += 1;
    return _completer.future;
  }

  void complete() {
    if (_completer.isCompleted) return;
    _completer.complete(const AnimalAssetBundle(animalImages: {}, noteImages: {}));
  }
}

class SpyGameService extends FakeGameService {
  @override
  MoveResult newGameFromGrid(Grid grid) => super.newGameFromGrid(grid);
}

Future<void> _pumpLaunch(WidgetTester tester, SudokuController controller, {AnimalAssetService? assetService}) async {
  await tester.binding.setSurfaceSize(const Size(1080, 1920));
  final screen = assetService == null
      ? LaunchScreen(controller: controller)
      : LaunchScreen(controller: controller, animalAssetService: assetService);
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pumpAndSettle();
}

Future<FakePreferencesStore> _buildPrefsWithSavedSession() async {
  final prefs = FakePreferencesStore();
  final seed = SudokuController(preferencesStore: prefs);
  await seed.ready;
  final editable = firstEditableCoord(seed.state);
  if (editable != null) {
    seed.onCellTapped(editable);
    seed.onDigitPressed(1);
  }
  return prefs;
}

Future<FakePreferencesStore> _buildPrefsWithCompletedSession() async {
  final prefs = FakePreferencesStore();
  final seed = SudokuController(preferencesStore: prefs);
  await seed.ready;
  seed.onShowSolution();
  return prefs;
}

void main() {
  testWidgets('LaunchScreen shows only Play when no saved session existed', (tester) async {
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;
    await _pumpLaunch(tester, controller);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('New game'), findsNothing);
  });

  testWidgets('LaunchScreen shows Resume and New game when session exists', (tester) async {
    final prefs = await _buildPrefsWithSavedSession();
    final controller = SudokuController(preferencesStore: prefs, gameService: SpyGameService());
    await controller.ready;
    await _pumpLaunch(tester, controller);
    expect(find.text('Play'), findsNothing);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('LaunchScreen shows only Play when saved session is already finished', (tester) async {
    final prefs = await _buildPrefsWithCompletedSession();
    final controller = SudokuController(preferencesStore: prefs);
    await controller.ready;
    await _pumpLaunch(tester, controller);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('New game'), findsNothing);
  });

  testWidgets('Resume does not start a new game', (tester) async {
    final prefs = await _buildPrefsWithSavedSession();
    final service = SpyGameService();
    final controller = SudokuController(preferencesStore: prefs, gameService: service);
    await controller.ready;
    await _pumpLaunch(tester, controller);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(service.newGameCalls, 0);
  });

  testWidgets('New game starts a new game', (tester) async {
    final prefs = await _buildPrefsWithSavedSession();
    final service = SpyGameService();
    final controller = SudokuController(preferencesStore: prefs, gameService: service);
    await controller.ready;
    await _pumpLaunch(tester, controller);
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    expect(service.newGameCalls, 1);
  });

  testWidgets('Play waits on splash for animal assets when content mode is animals', (tester) async {
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;
    controller.onContentModeChanged('animals');
    final service = DelayedAnimalAssetService();
    await _pumpLaunch(tester, controller, assetService: service);
    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(service.loadCalls, 1);
    expect(find.text('Please wait...'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('SuDoKu Playtime'), findsOneWidget);
    service.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LaunchScreen), findsNothing);
  });

  testWidgets('Play waits on splash for image assets when content mode is instruments', (tester) async {
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;
    controller.onContentModeChanged('instruments');
    final service = DelayedAnimalAssetService();
    await _pumpLaunch(tester, controller, assetService: service);
    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(service.loadCalls, 1);
    expect(find.text('Please wait...'), findsOneWidget);
    service.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LaunchScreen), findsNothing);
  });
}
