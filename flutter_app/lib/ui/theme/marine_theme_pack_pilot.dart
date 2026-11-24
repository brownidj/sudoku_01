import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/installed_theme_store.dart';
import 'package:flutter_app/ui/theme/local_theme_pack_installer.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_loader.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_pack_validator.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MarinePilotException extends ThemePackException {
  const MarinePilotException(super.message);
}

class MarinePilotCancelledException extends MarinePilotException {
  const MarinePilotCancelledException() : super('Pilot operation cancelled.');
}

/// Only the explicitly free Marine Life pilot is accepted by this test flow.
/// Apple's delivery version and the manifest's content version are independent.
class MarinePilotDescriptor {
  final int version;
  final int minimumAppBuild;
  final String archivePath;
  final int fileSizeBytes;
  final String checksum;

  const MarinePilotDescriptor._({
    required this.version,
    required this.minimumAppBuild,
    required this.archivePath,
    required this.fileSizeBytes,
    required this.checksum,
  });

  factory MarinePilotDescriptor.fromCatalogue(String text, int appBuild) {
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic> ||
          json['catalogue_version'] is! int ||
          (json['catalogue_version'] as int) < 1 ||
          json['minimum_supported_app_build'] is! int ||
          (json['minimum_supported_app_build'] as int) < 0 ||
          json['themes'] is! List) {
        throw const FormatException('Invalid pilot catalogue.');
      }
      final matches = (json['themes'] as List).where(
        (entry) => entry is Map<String, dynamic> && entry['id'] == 'marine',
      );
      if (matches.length != 1) {
        throw const FormatException(
          'Expected one Marine Life catalogue entry.',
        );
      }
      final entry = matches.single as Map<String, dynamic>;
      final version = entry['version'];
      final minimum = entry['minimum_app_build'];
      final size = entry['file_size_bytes'];
      final checksum = entry['sha256'];
      if (entry['active'] != true ||
          entry['is_free'] != true ||
          entry['product_id'] != null ||
          entry['apple_asset_pack_id'] != 'marine' ||
          version is! int ||
          version < 1 ||
          minimum is! int ||
          minimum < 0 ||
          size is! int ||
          size < 1 ||
          size > 64 * 1024 * 1024 ||
          checksum is! String ||
          !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(checksum) ||
          entry['archive_path'] != 'ThemePacks/marine_v$version.zip') {
        throw const FormatException(
          'Invalid or unavailable free Marine Life pack.',
        );
      }
      if (minimum > appBuild ||
          (json['minimum_supported_app_build'] as int) > appBuild) {
        throw const FormatException('This pilot requires a newer app build.');
      }
      return MarinePilotDescriptor._(
        version: version,
        minimumAppBuild: minimum,
        archivePath: entry['archive_path'] as String,
        fileSizeBytes: size,
        checksum: checksum.toLowerCase(),
      );
    } on FormatException catch (error) {
      throw MarinePilotException(error.message);
    }
  }
}

/// Coordinates the native transport and existing local installer. No operation
/// runs automatically at game startup. All destructive actions target marine.
class MarineThemePackPilot {
  final AppleThemePackDelivery delivery;
  final ThemeStoragePaths storagePaths;
  final int appBuild;
  final InstalledThemeStore store;
  final LocalThemePackInstaller installer;
  bool _busy = false;
  bool _cancelled = false;
  String? _activePack;
  bool usedCachedCatalogue = false;
  String? catalogueWarning;

  MarineThemePackPilot({
    required this.delivery,
    required this.storagePaths,
    required this.appBuild,
  }) : store = InstalledThemeStore(storagePaths: storagePaths),
       installer = LocalThemePackInstaller(storagePaths: storagePaths);

  static Future<MarineThemePackPilot> create() async {
    final package = await PackageInfo.fromPlatform();
    final build = int.tryParse(package.buildNumber);
    if (build == null) {
      throw const MarinePilotException(
        'Cannot determine the app build number.',
      );
    }
    return MarineThemePackPilot(
      delivery: AppleThemePackDelivery(),
      storagePaths: await ThemeStoragePaths.applicationSupport(),
      appBuild: build,
    );
  }

  File get _cache =>
      File('${storagePaths.rootDirectory.path}/catalogue/apple_pilot.json');

  Future<MarinePilotDescriptor?> cachedCatalogue() async {
    try {
      return MarinePilotDescriptor.fromCatalogue(
        await _readSmallFile(_cache),
        appBuild,
      );
    } on FileSystemException {
      return null;
    } on ThemePackException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<MarinePilotDescriptor> fetchCatalogue() => _operation(() async {
    usedCachedCatalogue = false;
    catalogueWarning = null;
    File? temporary;
    try {
      _activePack = 'theme_catalogue';
      final path = await delivery.ensureAvailable(
        assetPackId: 'theme_catalogue',
        relativePath: 'ThemeCatalogue/catalogue.json',
      );
      _checkCancelled();
      final text = await _readSmallFile(File(path));
      final descriptor = MarinePilotDescriptor.fromCatalogue(text, appBuild);
      _checkCancelled();
      await _cache.parent.create(recursive: true);
      temporary = File('${_cache.path}.tmp');
      await temporary.writeAsString(text, flush: true);
      _checkCancelled();
      await temporary.rename(_cache.path);
      return descriptor;
    } catch (error) {
      _checkCancelled();
      final cached = await cachedCatalogue();
      if (cached == null) rethrow;
      usedCachedCatalogue = true;
      catalogueWarning = error.toString();
      return cached;
    } finally {
      if (temporary != null && await temporary.exists()) {
        await temporary.delete();
      }
    }
  });

  Future<ThemeDefinition> downloadAndInstall(
    MarinePilotDescriptor descriptor, {
    void Function(String)? onStage,
  }) => _operation(() async {
    Directory? temporary;
    RandomAccessFile? output;
    var committed = false;
    try {
      if (descriptor.minimumAppBuild > appBuild) {
        throw const MarinePilotException(
          'This pilot requires a newer app build.',
        );
      }
      final installed = await store.readInstalledTheme('marine');
      if (installed != null) {
        if (installed.version != descriptor.version) {
          throw const MarinePilotException(
            'Remove the pilot installation before testing a different version.',
          );
        }
        return (await loadInstalled())!;
      }
      _checkCancelled();
      _activePack = 'marine';
      onStage?.call('Downloading Marine Life…');
      final path = await delivery.ensureAvailable(
        assetPackId: 'marine',
        relativePath: descriptor.archivePath,
      );
      _activePack = null;
      _checkCancelled();
      onStage?.call('Verifying ZIP size and SHA-256…');
      final source = File(path);
      if (await source.length() != descriptor.fileSizeBytes) {
        throw const MarinePilotException(
          'Downloaded ZIP size does not match the catalogue.',
        );
      }
      await storagePaths.ensureBaseDirectories();
      temporary = await storagePaths.tempDirectory.createTemp('marine_pilot_');
      final zip = File('${temporary.path}/marine.zip');
      output = await zip.open(mode: FileMode.write);
      var bytes = 0;
      await for (final chunk in source.openRead()) {
        _checkCancelled();
        bytes += chunk.length;
        if (bytes > descriptor.fileSizeBytes) {
          throw const MarinePilotException(
            'Downloaded ZIP exceeds its declared size.',
          );
        }
        await output.writeFrom(chunk);
      }
      await output.flush();
      await output.close();
      output = null;
      if (bytes != descriptor.fileSizeBytes ||
          (await sha256.bind(zip.openRead()).first).toString() !=
              descriptor.checksum) {
        throw const MarinePilotException(
          'Downloaded ZIP failed its size/checksum check.',
        );
      }
      _checkCancelled();
      onStage?.call('Validating manifest and installing…');
      await installer.installFromZip(
        zip,
        expectedThemeId: 'marine',
        expectedVersion: descriptor.version,
        appBuild: appBuild,
        checkCancelled: _checkCancelled,
      );
      committed = true;
      // Keep Apple's delivery copy until the explicit cleanup button is used.
      // Once installation commits, a late cancellation must not undo success.
      return (await loadInstalled())!;
    } catch (_) {
      if (!committed) _checkCancelled();
      rethrow;
    } finally {
      await output?.close();
      if (temporary != null && await temporary.exists()) {
        await temporary.delete(recursive: true);
      }
    }
  });

  /// Performs full local asset validation and uses the same loader as other
  /// installed themes. This method never calls the native delivery service.
  Future<ThemeDefinition?> loadInstalled() async {
    final installed = await store.readInstalledTheme('marine');
    if (installed == null) return null;
    final validated = await const ThemePackValidator().validate(
      Directory(installed.rootPath),
    );
    if (!installed.validated ||
        validated.manifest.themeId != 'marine' ||
        validated.manifest.themeVersion != installed.version) {
      throw const MarinePilotException(
        'Installed Marine Life metadata is inconsistent.',
      );
    }
    return RepositoryThemeLoader(
      installedThemeStore: store,
    ).loadInstalledTheme('marine');
  }

  Future<void> removeInstallation() =>
      _operation(() => store.removeTheme('marine'));

  Future<void> removeDeliveryCopy() => _operation(() async {
    if (await loadInstalled() == null) {
      throw const MarinePilotException(
        'Install and verify the pilot before removing the delivery copy.',
      );
    }
    await delivery.removeAssetPack('marine');
  });

  Future<void> cancel() async {
    if (!_busy) return;
    _cancelled = true;
    final pack = _activePack;
    if (pack != null) await delivery.cancelDownload(pack);
  }

  Future<T> _operation<T>(Future<T> Function() action) async {
    if (_busy) {
      throw const MarinePilotException('A pilot operation is already running.');
    }
    _busy = true;
    _cancelled = false;
    try {
      return await action();
    } finally {
      _busy = false;
      _activePack = null;
    }
  }

  void _checkCancelled() {
    if (_cancelled) throw const MarinePilotCancelledException();
  }

  Future<String> _readSmallFile(File file) async {
    if (await file.length() > 2 * 1024 * 1024) {
      throw const MarinePilotException('Pilot catalogue is too large.');
    }
    // Bound the read as well as the initial stat if a native update replaces it.
    final bytes = <int>[];
    await for (final chunk in file.openRead()) {
      if (bytes.length + chunk.length > 2 * 1024 * 1024) {
        throw const MarinePilotException('Pilot catalogue is too large.');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes);
  }
}
