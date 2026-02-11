import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/candidate_selection_controller.dart';

void main() {
  test('CandidateSelectionController manages visibility and selection state', () {
    final controller = CandidateSelectionController();
    var notifyCount = 0;
    controller.addListener(() => notifyCount += 1);

    expect(controller.visible, isFalse);
    expect(controller.candidateCoord, isNull);
    expect(controller.candidateDigits, isEmpty);

    final coord = const Coord(1, 2);
    controller.show(coord, const [1, 3, 5]);
    expect(controller.visible, isTrue);
    expect(controller.candidateCoord, coord);
    expect(controller.candidateDigits, const [1, 3, 5]);
    expect(notifyCount, 1);

    controller.refresh();
    expect(notifyCount, 2);

    controller.hide();
    expect(controller.visible, isFalse);
    expect(controller.candidateCoord, isNull);
    expect(controller.candidateDigits, isEmpty);
    expect(notifyCount, 3);

    controller.hide();
    expect(notifyCount, 3);
  });
}
