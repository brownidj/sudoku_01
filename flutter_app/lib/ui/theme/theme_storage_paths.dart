import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThemeStoragePaths {
  final Directory rootDirectory;

  const ThemeStoragePaths(this.rootDirectory);

  static Future<ThemeStoragePaths> applicationSupport() async {
    final support = await getApplicationSupportDirectory();
    return ThemeStoragePaths(Directory(p.join(support.path, 'themes')));
  }

  Directory get installedDirectory =>
      Directory(p.join(rootDirectory.path, 'installed'));

  Directory get tempDirectory => Directory(p.join(rootDirectory.path, 'temp'));

  Directory themeDirectory(String themeId) =>
      Directory(p.join(installedDirectory.path, themeId));

  Directory versionsDirectory(String themeId) =>
      Directory(p.join(themeDirectory(themeId).path, 'versions'));

  Directory versionDirectory(String themeId, int version) =>
      Directory(p.join(versionsDirectory(themeId).path, '$version'));

  Directory installingDirectory(String themeId, int version) =>
      Directory(p.join(versionsDirectory(themeId).path, '$version.installing'));

  File currentFile(String themeId) =>
      File(p.join(themeDirectory(themeId).path, 'current.json'));

  Future<void> ensureBaseDirectories() async {
    await installedDirectory.create(recursive: true);
    await tempDirectory.create(recursive: true);
  }
}
