import 'package:flutter/foundation.dart';

class AppDebug {
  static const bool enabled = bool.fromEnvironment(
    'APP_DEBUG',
    defaultValue: false,
  );

  static void log(String message) {
    if (!enabled || !kDebugMode) {
      return;
    }
    debugPrint(message);
  }
}
