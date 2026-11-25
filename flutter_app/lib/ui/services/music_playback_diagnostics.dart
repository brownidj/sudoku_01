import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Opt-in local QA trace; never enabled in release builds or sent anywhere.
class MusicPlaybackDiagnostics {
  static const enabled =
      !kReleaseMode && bool.fromEnvironment('MUSIC_PLAYBACK_DIAGNOSTICS');
  static final _events = <Map<String, Object?>>[];
  static Future<void> _writes = Future<void>.value();

  static Future<void> record(String event, Map<String, Object?> details) {
    if (!enabled) return Future<void>.value();
    _writes = _writes
        .then((_) async {
          _events.add({
            'event': event,
            'time': DateTime.now().toUtc().toIso8601String(),
            ...details,
          });
          if (_events.length > 100) _events.removeAt(0);
          final support = await getApplicationSupportDirectory();
          await File(
            '${support.path}/music_playback_diagnostics.json',
          ).writeAsString(jsonEncode(_events), flush: true);
        })
        .catchError((Object _) {
          /* Diagnostics must never affect playback. */
        });
    return _writes;
  }
}
