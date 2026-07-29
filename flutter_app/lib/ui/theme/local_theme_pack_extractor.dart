import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:flutter_app/ui/theme/theme_pack_path_safety.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:path/path.dart' as p;

class LocalThemePackExtractor {
  static const int maxArchiveFileBytes = 20 * 1024 * 1024;

  final ThemeStoragePaths storagePaths;

  const LocalThemePackExtractor({required this.storagePaths});

  Future<Directory> extractToStaging(File zipFile) async {
    if (!await zipFile.exists()) {
      throw ThemeZipNotFoundException(zipFile.path);
    }
    await storagePaths.ensureBaseDirectories();
    final stagingDirectory = await Directory(
      p.join(
        storagePaths.tempDirectory.path,
        '${DateTime.now().microsecondsSinceEpoch}.staging',
      ),
    ).create(recursive: true);
    try {
      final archive = _decode(zipFile, await zipFile.readAsBytes());
      for (final entry in archive) {
        final relativePath = safeThemeRelativePath(entry.name);
        rejectBlockedThemeFileExtension(relativePath);
        if (entry.isSymbolicLink) {
          throw UnsafeThemeArchivePathException(entry.name);
        }
        if (entry.isDirectory) {
          await Directory(
            p.join(stagingDirectory.path, relativePath),
          ).create(recursive: true);
          continue;
        }
        if (!entry.isFile) {
          continue;
        }
        if (entry.size > maxArchiveFileBytes) {
          throw InvalidThemeZipException(zipFile.path);
        }
        final outputFile = File(p.join(stagingDirectory.path, relativePath));
        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(entry.content as List<int>, flush: true);
      }
      await archive.clear();
      return stagingDirectory;
    } catch (_) {
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  Archive _decode(File zipFile, List<int> bytes) {
    if (!_hasZipSignature(bytes)) {
      throw InvalidThemeZipException(zipFile.path);
    }
    try {
      return ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw InvalidThemeZipException(zipFile.path);
    }
  }

  bool _hasZipSignature(List<int> bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4b &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
  }
}
