import 'package:flutter/foundation.dart';

class ScreenshotMode {
  static const bool enabled = bool.fromEnvironment(
    'SCREENSHOT_MODE',
    defaultValue: false,
  );
  static const String scene = String.fromEnvironment('SCREENSHOT_SCENE');
  static const String theme = String.fromEnvironment('SCREENSHOT_THEME');
  static const String device = String.fromEnvironment('SCREENSHOT_DEVICE');
  static const String brandPlatform = String.fromEnvironment(
    'SCREENSHOT_BRAND_PLATFORM',
  );
  static const String orientation = String.fromEnvironment(
    'SCREENSHOT_ORIENTATION',
  );
  static const String languageCode = String.fromEnvironment(
    'SCREENSHOT_LANGUAGE',
  );
  static const bool captureAudio = bool.fromEnvironment(
    'SCREENSHOT_CAPTURE_AUDIO',
    defaultValue: false,
  );
  static const int moves = int.fromEnvironment(
    'SCREENSHOT_MOVES',
    defaultValue: 0,
  );

  static bool get isHome => scene == 'home';
  static bool get isDrawerOpen => scene == 'drawer_open';
  static bool get isNewGame => scene == 'new_game';
  static bool get isPartialProgress => scene == 'partial_progress';
  static bool get isCelebration => scene == 'celebration';
  static bool get isVideoFinishCelebration =>
      scene == 'video_finish_celebration';

  static String get outputFilename {
    if (!enabled) {
      return '';
    }
    switch (scene) {
      case 'home':
        return '01_home.png';
      case 'drawer_open':
        return '02_drawer_open.png';
      case 'new_game':
        switch (theme) {
          case 'numbers':
            return '03_new_game_numbers.png';
          case 'animals':
            return '04_new_game_animals.png';
          case 'butterflies':
            return '05_new_game_butterflies.png';
        }
      case 'partial_progress':
        if (theme == 'shells') {
          return '06_shells_after_16_moves.png';
        }
      case 'celebration':
        if (theme == 'animals') {
          return '07_celebration.png';
        }
      case 'video_finish_celebration':
        if (theme == 'animals') {
          return '01_finish_and_celebration.mp4';
        }
        if (theme == 'butterflies') {
          return '02_finish_and_celebration_butterflies.mp4';
        }
    }
    throw StateError(
      'Unsupported screenshot mode combination: '
      'scene=$scene theme=$theme moves=$moves device=$device orientation=$orientation',
    );
  }

  static bool get requiresPremiumTheme =>
      theme == 'butterflies' || theme == 'shells' || theme == 'old_opera';

  static void reportReady() {
    if (!enabled) {
      return;
    }
    debugPrint('SCREENSHOT_READY:$outputFilename');
  }

  static void reportDone() {
    if (!enabled) {
      return;
    }
    debugPrint('SCREENSHOT_DONE:$outputFilename');
  }

  static void reportCelebrationAudioAsset(String asset) {
    if (!enabled) {
      return;
    }
    debugPrint('SCREENSHOT_CELEBRATION_AUDIO:$asset');
  }
}
