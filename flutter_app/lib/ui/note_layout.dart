int noteGridSize(int noteCount) {
  return noteCount <= 4 ? 2 : 3;
}

int bestNoteSize(double targetPx, Iterable<int> sizes) {
  final sorted = sizes.toList()..sort();
  if (sorted.isEmpty) {
    return 0;
  }
  var best = sorted.first;
  for (final size in sorted) {
    if (size <= targetPx) {
      best = size;
    } else {
      break;
    }
  }
  return best;
}
