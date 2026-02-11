import 'package:flutter/foundation.dart';
import 'package:flutter_app/domain/types.dart';

class CandidateSelectionController extends ChangeNotifier {
  bool _visible = false;
  List<int> _candidateDigits = const [];
  Coord? _candidateCoord;

  bool get visible => _visible;
  List<int> get candidateDigits => _candidateDigits;
  Coord? get candidateCoord => _candidateCoord;

  void show(Coord coord, List<int> digits) {
    _visible = true;
    _candidateCoord = coord;
    _candidateDigits = digits;
    notifyListeners();
  }

  void hide() {
    if (!_visible && _candidateCoord == null && _candidateDigits.isEmpty) {
      return;
    }
    _visible = false;
    _candidateCoord = null;
    _candidateDigits = const [];
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
