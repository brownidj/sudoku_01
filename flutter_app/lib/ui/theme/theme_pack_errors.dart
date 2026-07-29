enum ThemePackDuplicateComparison { newer, identical, older }

abstract class ThemePackException implements Exception {
  final String message;

  const ThemePackException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ThemeZipNotFoundException extends ThemePackException {
  const ThemeZipNotFoundException(String path)
    : super('Theme ZIP file not found: $path');
}

class InvalidThemeZipException extends ThemePackException {
  const InvalidThemeZipException(String path)
    : super('Invalid theme ZIP archive: $path');
}

class MissingThemeManifestException extends ThemePackException {
  const MissingThemeManifestException() : super('Missing manifest.json');
}

class InvalidThemeManifestException extends ThemePackException {
  const InvalidThemeManifestException(super.message);
}

class UnsupportedThemeManifestVersionException extends ThemePackException {
  const UnsupportedThemeManifestVersionException(int version)
    : super('Unsupported manifest schema version: $version');
}

class MissingThemeAssetException extends ThemePackException {
  const MissingThemeAssetException(String path)
    : super('Missing theme asset: $path');
}

class ThemeChecksumMismatchException extends ThemePackException {
  const ThemeChecksumMismatchException(String path)
    : super('Checksum mismatch for theme asset: $path');
}

class DuplicateThemePackException extends ThemePackException {
  final String themeId;
  final int installedVersion;
  final int incomingVersion;
  final ThemePackDuplicateComparison comparison;

  DuplicateThemePackException({
    required this.themeId,
    required this.installedVersion,
    required this.incomingVersion,
    required this.comparison,
  }) : super(
         'Theme $themeId is already installed '
         '(installed=$installedVersion, incoming=$incomingVersion, '
         'comparison=${comparison.name})',
       );
}

class ThemeRepositoryWriteException extends ThemePackException {
  const ThemeRepositoryWriteException(super.message);
}

class UnsafeThemeArchivePathException extends ThemePackException {
  const UnsafeThemeArchivePathException(String path)
    : super('Unsafe theme archive path: $path');
}
