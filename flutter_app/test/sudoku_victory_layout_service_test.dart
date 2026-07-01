import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/services/sudoku_victory_layout_service.dart';

void main() {
  const service = SudokuVictoryLayoutService();

  test('centers the visible celebration block on phone layouts', () {
    final centerY = service.computeCenterY(
      shortestSide: 393,
      tilesBottom: 900,
      controlsTop: 1400,
    );

    expect(centerY, 1257);
  });

  test('keeps tablet celebration at least 20px below the game area', () {
    final centerY = service.computeCenterY(
      shortestSide: 1024,
      tilesBottom: 1200,
      controlsTop: 1450,
    );

    expect(centerY, 1432);
  });

  test('centers the visible celebration block on tablet when space allows', () {
    final centerY = service.computeCenterY(
      shortestSide: 1024,
      tilesBottom: 900,
      controlsTop: 1600,
    );

    expect(centerY, 1357);
  });
}
