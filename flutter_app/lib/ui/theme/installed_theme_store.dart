import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/ui/theme/installed_theme.dart';
import 'package:flutter_app/ui/theme/theme_manifest.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:path/path.dart' as p;

class InstalledThemeStore {
  final ThemeStoragePaths storagePaths;

  const InstalledThemeStore({required this.storagePaths});

  Future<List<InstalledTheme>> listInstalledThemes() async {
    await storagePaths.ensureBaseDirectories();
    final root = storagePaths.installedDirectory;
    if (!await root.exists()) {
      return const <InstalledTheme>[];
    }
    final installed = <InstalledTheme>[];
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! Directory) {
        continue;
      }
      final theme = await readInstalledTheme(p.basename(entry.path));
      if (theme != null) {
        installed.add(theme);
      }
    }
    installed.sort((a, b) => a.id.compareTo(b.id));
    return installed;
  }

  Future<InstalledTheme?> readInstalledTheme(String themeId) async {
    final currentFile = storagePaths.currentFile(themeId);
    if (!await currentFile.exists()) {
      return null;
    }
    final json = jsonDecode(await currentFile.readAsString());
    if (json is! Map<String, dynamic>) {
      throw InvalidThemeManifestException('Invalid current.json for $themeId.');
    }
    final version = json['active_version'];
    final installedAt = json['installed_at'];
    final validated = json['validated'];
    if (version is! int || installedAt is! String || validated is! bool) {
      throw InvalidThemeManifestException('Invalid current.json for $themeId.');
    }
    final rootDirectory = storagePaths.versionDirectory(themeId, version);
    if (!await rootDirectory.exists()) {
      return null;
    }
    return InstalledTheme(
      id: themeId,
      version: version,
      installedAt: DateTime.parse(installedAt),
      validated: validated,
      rootPath: rootDirectory.path,
    );
  }

  Future<ThemeManifest> readManifest(InstalledTheme installedTheme) async {
    final manifestFile = File(p.join(installedTheme.rootPath, 'manifest.json'));
    if (!await manifestFile.exists()) {
      throw const MissingThemeManifestException();
    }
    return ThemeManifest.fromJsonText(await manifestFile.readAsString());
  }

  Future<void> writeCurrent({
    required ThemeManifest manifest,
    required DateTime installedAt,
  }) async {
    final themeDirectory = storagePaths.themeDirectory(manifest.themeId);
    await themeDirectory.create(recursive: true);
    final currentFile = storagePaths.currentFile(manifest.themeId);
    final payload = <String, Object>{
      'active_version': manifest.themeVersion,
      'installed_at': installedAt.toUtc().toIso8601String(),
      'validated': true,
    };
    await currentFile.writeAsString(jsonEncode(payload));
  }

  Future<bool> validateInstallation(String themeId) async {
    final installedTheme = await readInstalledTheme(themeId);
    if (installedTheme == null || !installedTheme.validated) {
      return false;
    }
    final manifest = await readManifest(installedTheme);
    if (manifest.themeId != themeId ||
        manifest.themeVersion != installedTheme.version) {
      return false;
    }
    for (final relativePath in manifest.referencedPaths()) {
      if (!await File(p.join(installedTheme.rootPath, relativePath)).exists()) {
        return false;
      }
    }
    return true;
  }

  Future<void> removeTheme(String themeId) async {
    final themeDirectory = storagePaths.themeDirectory(themeId);
    if (await themeDirectory.exists()) {
      await themeDirectory.delete(recursive: true);
    }
  }
}
