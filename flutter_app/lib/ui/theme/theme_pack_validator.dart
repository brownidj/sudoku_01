import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_app/ui/theme/theme_manifest.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_pack_path_safety.dart';
import 'package:path/path.dart' as p;

class ValidatedThemePack {
  final ThemeManifest manifest;
  final Directory rootDirectory;

  const ValidatedThemePack({
    required this.manifest,
    required this.rootDirectory,
  });
}

class ThemePackValidator {
  const ThemePackValidator();

  Future<ValidatedThemePack> validate(Directory stagingDirectory) async {
    final manifestFile = await _findManifest(stagingDirectory);
    final rootDirectory = manifestFile.parent;
    final manifest = ThemeManifest.fromJsonText(
      await manifestFile.readAsString(),
    );
    await _validateReferencedAssets(manifest, rootDirectory);
    await _validateChecksums(manifest, rootDirectory);
    return ValidatedThemePack(manifest: manifest, rootDirectory: rootDirectory);
  }

  Future<File> _findManifest(Directory stagingDirectory) async {
    if (!await stagingDirectory.exists()) {
      throw const MissingThemeManifestException();
    }
    final manifests = <File>[];
    await for (final entry in stagingDirectory.list(recursive: true)) {
      if (entry is File && p.basename(entry.path) == 'manifest.json') {
        manifests.add(entry);
      }
    }
    if (manifests.isEmpty) {
      throw const MissingThemeManifestException();
    }
    if (manifests.length > 1) {
      throw const InvalidThemeManifestException(
        'Theme pack must contain exactly one manifest.json.',
      );
    }
    return manifests.single;
  }

  Future<void> _validateReferencedAssets(
    ThemeManifest manifest,
    Directory rootDirectory,
  ) async {
    safeThemeRelativePath(manifest.previewPath);
    requireSupportedAssetExtension(
      path: manifest.previewPath,
      allowedExtensions: supportedThemeImageExtensions,
      assetType: 'preview image',
    );
    await _requireFile(rootDirectory, manifest.previewPath);

    for (final tile in manifest.tiles) {
      safeThemeRelativePath(tile.path);
      requireSupportedAssetExtension(
        path: tile.path,
        allowedExtensions: supportedThemeImageExtensions,
        assetType: 'tile image',
      );
      await _requireFile(rootDirectory, tile.path);
    }

    for (final audioPath in manifest.audio.referencedPaths()) {
      safeThemeRelativePath(audioPath);
      requireSupportedAssetExtension(
        path: audioPath,
        allowedExtensions: supportedThemeAudioExtensions,
        assetType: 'audio',
      );
      await _requireFile(rootDirectory, audioPath);
    }
  }

  Future<void> _validateChecksums(
    ThemeManifest manifest,
    Directory rootDirectory,
  ) async {
    for (final entry in manifest.checksums.entries) {
      final relativePath = safeThemeRelativePath(entry.key);
      final file = await _requireFile(rootDirectory, relativePath);
      final digest = sha256.convert(await file.readAsBytes()).toString();
      if (digest != entry.value) {
        throw ThemeChecksumMismatchException(relativePath);
      }
    }
  }

  Future<File> _requireFile(
    Directory rootDirectory,
    String relativePath,
  ) async {
    final normalizedPath = safeThemeRelativePath(relativePath);
    final file = File(p.join(rootDirectory.path, normalizedPath));
    final canonicalRoot = p.canonicalize(rootDirectory.path);
    final canonicalFile = p.canonicalize(file.path);
    if (!p.isWithin(canonicalRoot, canonicalFile)) {
      throw UnsafeThemeArchivePathException(relativePath);
    }
    if (!await file.exists()) {
      throw MissingThemeAssetException(relativePath);
    }
    return file;
  }
}
