import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/app/sudoku_app.dart';
import 'package:flutter_app/ui/theme/local_theme_pack_developer_installer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    ScreenshotMode.enabled
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await LocalThemePackDeveloperInstaller.maybeInstall();
  runApp(const SudokuApp());
}
