import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/styles.dart';

CellVm _cell({bool given = false, bool selected = false}) {
  return CellVm(
    coord: const Coord(0, 0),
    value: given ? 1 : null,
    given: given,
    notes: const [],
    selected: selected,
    conflicted: false,
    incorrect: false,
    solutionAdded: false,
    correct: false,
    reverted: false,
  );
}

void main() {
  test('given cells use the completed-grid given highlight during play', () {
    final model = const BoardTheme(styleModern).cellModel(
      cell: _cell(given: true),
      gameOver: false,
      peerRowCol: false,
      peerBox: false,
    );

    expect(model.background, styleModern.highlightGiven);
  });

  test('selected given cells keep the given fill and selection outline', () {
    final model = const BoardTheme(styleModern).cellModel(
      cell: _cell(given: true, selected: true),
      gameOver: false,
      peerRowCol: true,
      peerBox: true,
    );

    expect(model.background, styleModern.highlightGiven);
    expect(model.showSelection, isTrue);
  });
}
