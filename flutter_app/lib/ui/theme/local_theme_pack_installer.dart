import 'dart:io';

import 'package:flutter_app/ui/theme/bundled_theme_repository.dart';
import 'package:flutter_app/ui/theme/installed_theme.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/local_theme_pack_extractor.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_pack_validator.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:path/path.dart' as p;

class LocalThemePackInstaller {
  final ThemeStoragePaths storagePaths;
  final BundledThemeRepository bundledRepository;
  final InstalledThemeStore installedThemeStore;
  final LocalThemePackExtractor extractor;
  final ThemePackValidator validator;

  LocalThemePackInstaller({
    required this.storagePaths,
    this.bundledRepository = const BundledThemeRepository(),
    InstalledThemeStore? installedThemeStore,
    LocalThemePackExtractor? extractor,
    this.validator = const ThemePackValidator(),
  }) : installedThemeStore =
           installedThemeStore ??
           InstalledThemeStore(storagePaths: storagePaths),
       extractor =
           extractor ?? LocalThemePackExtractor(storagePaths: storagePaths);

  Future<InstalledTheme> installFromZip(File zipFile) async {
    Directory? stagingDirectory;
    Directory? installingDirectory;
    Directory? finalDirectory;
    try {
      stagingDirectory = await extractor.extractToStaging(zipFile);
      final validatedPack = await validator.validate(stagingDirectory);
      final manifest = validatedPack.manifest;
      await _rejectDuplicate(manifest.themeId, manifest.themeVersion);

      await storagePaths
          .versionsDirectory(manifest.themeId)
          .create(recursive: true);
      installingDirectory = storagePaths.installingDirectory(
        manifest.themeId,
        manifest.themeVersion,
      );
      finalDirectory = storagePaths.versionDirectory(
        manifest.themeId,
        manifest.themeVersion,
      );
      await _prepareEmptyDirectory(installingDirectory);
      if (await finalDirectory.exists()) {
        throw ThemeRepositoryWriteException(
          'Theme version directory already exists: ${finalDirectory.path}',
        );
      }

      await _copyDirectory(validatedPack.rootDirectory, installingDirectory);
      await installingDirectory.rename(finalDirectory.path);
      installingDirectory = null;
      final installedAt = DateTime.now().toUtc();
      try {
        await installedThemeStore.writeCurrent(
          manifest: manifest,
          installedAt: installedAt,
        );
      } catch (error) {
        if (await finalDirectory.exists()) {
          await finalDirectory.delete(recursive: true);
        }
        throw ThemeRepositoryWriteException(
          'Failed to write current.json for ${manifest.themeId}: $error',
        );
      }

      return InstalledTheme(
        id: manifest.themeId,
        version: manifest.themeVersion,
        installedAt: installedAt,
        validated: true,
        rootPath: finalDirectory.path,
      );
    } on ThemePackException {
      rethrow;
    } catch (error) {
      throw ThemeRepositoryWriteException(
        'Local theme installation failed: $error',
      );
    } finally {
      if (installingDirectory != null && await installingDirectory.exists()) {
        await installingDirectory.delete(recursive: true);
      }
      if (stagingDirectory != null && await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
    }
  }

  Future<void> _rejectDuplicate(String themeId, int incomingVersion) async {
    if (BundledThemeRepository.hasTheme(themeId)) {
      final installedVersion = BundledThemeRepository.themeDefinitionFor(
        themeId,
      ).version;
      throw DuplicateThemePackException(
        themeId: themeId,
        installedVersion: installedVersion,
        incomingVersion: incomingVersion,
        comparison: _compareVersions(installedVersion, incomingVersion),
      );
    }

    final installedTheme = await installedThemeStore.readInstalledTheme(
      themeId,
    );
    if (installedTheme == null) {
      return;
    }
    throw DuplicateThemePackException(
      themeId: themeId,
      installedVersion: installedTheme.version,
      incomingVersion: incomingVersion,
      comparison: _compareVersions(installedTheme.version, incomingVersion),
    );
  }

  ThemePackDuplicateComparison _compareVersions(
    int installedVersion,
    int incomingVersion,
  ) {
    if (incomingVersion > installedVersion) {
      return ThemePackDuplicateComparison.newer;
    }
    if (incomingVersion < installedVersion) {
      return ThemePackDuplicateComparison.older;
    }
    return ThemePackDuplicateComparison.identical;
  }

  Future<void> _prepareEmptyDirectory(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relativePath = p.relative(entity.path, from: source.path);
      final targetPath = p.join(destination.path, relativePath);
      if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      } else if (entity is File) {
        final targetFile = File(targetPath);
        await targetFile.parent.create(recursive: true);
        await entity.copy(targetFile.path);
      }
    }
  }
}
