class DebugToggleService {
  final List<DateTime> _tapTimestamps = <DateTime>[];

  bool registerVersionTap(DateTime now) {
    _tapTimestamps.add(now);
    _tapTimestamps.removeWhere(
      (tapTime) => now.difference(tapTime) > const Duration(seconds: 4),
    );
    if (_tapTimestamps.length < 7) {
      return false;
    }
    _tapTimestamps.clear();
    return true;
  }
}
