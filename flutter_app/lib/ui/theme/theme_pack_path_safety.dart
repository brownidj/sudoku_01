import 'package:flutter_app/ui/theme/theme_pack_errors.dart';
import 'package:path/path.dart' as p;

const _blockedExtensions = <String>{
  '.apk',
  '.app',
  '.bat',
  '.cmd',
  '.dll',
  '.dylib',
  '.exe',
  '.ipa',
  '.js',
  '.sh',
  '.so',
};

const supportedThemeImageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
};

const supportedThemeAudioExtensions = <String>{'.m4a', '.mp3', '.wav'};

String safeThemeRelativePath(String path) {
  final normalizedInput = path.replaceAll('\\', '/').trim();
  if (normalizedInput.isEmpty ||
      p.posix.isAbsolute(normalizedInput) ||
      normalizedInput.startsWith('/')) {
    throw UnsafeThemeArchivePathException(path);
  }
  final normalized = p.posix.normalize(normalizedInput);
  final parts = p.posix.split(normalized);
  if (normalized == '.' || parts.any((part) => part == '..')) {
    throw UnsafeThemeArchivePathException(path);
  }
  return normalized;
}

void rejectBlockedThemeFileExtension(String path) {
  final extension = p.extension(path).toLowerCase();
  if (_blockedExtensions.contains(extension)) {
    throw UnsafeThemeArchivePathException(path);
  }
}

void requireSupportedAssetExtension({
  required String path,
  required Set<String> allowedExtensions,
  required String assetType,
}) {
  final extension = p.extension(path).toLowerCase();
  if (!allowedExtensions.contains(extension)) {
    throw InvalidThemeManifestException(
      'Unsupported $assetType asset format for $path.',
    );
  }
}
