enum ThemeSource { bundled, downloaded }

enum ThemeInstallationState {
  notInstalled,
  downloading,
  installing,
  installed,
  updateAvailable,
  failed,
}

class ThemeSummary {
  final String id;
  final String displayName;
  final String description;
  final String previewImage;
  final ThemeSource source;
  final bool isInstalled;
  final bool isOwned;
  final bool hasUpdate;
  final int version;

  const ThemeSummary({
    required this.id,
    required this.displayName,
    required this.description,
    required this.previewImage,
    required this.source,
    required this.isInstalled,
    required this.isOwned,
    required this.hasUpdate,
    required this.version,
  });
}

class ThemeDefinition {
  final String id;
  final String displayName;
  final List<ThemeTile> tiles;
  final ThemeAudio? audio;
  final ThemeColours colours;
  final ThemeTypography? typography;
  final int version;

  const ThemeDefinition({
    required this.id,
    required this.displayName,
    required this.tiles,
    required this.audio,
    required this.colours,
    required this.typography,
    required this.version,
  });

  ThemeTile? tileForDigit(int digit) {
    if (digit < 1 || digit > tiles.length) {
      return null;
    }
    return tiles[digit - 1];
  }
}

class ThemeTile {
  final String id;
  final String imagePath;
  final String? accessibilityLabel;
  final String displayName;
  final String label;
  final String? noteImagePath;
  final String? celebrationImagePath;
  final Map<String, String> variantImagePaths;
  final Map<String, String> variantNoteImagePaths;

  const ThemeTile({
    required this.id,
    required this.imagePath,
    required this.accessibilityLabel,
    required this.displayName,
    required this.label,
    this.noteImagePath,
    this.celebrationImagePath,
    this.variantImagePaths = const <String, String>{},
    this.variantNoteImagePaths = const <String, String>{},
  });

  String imagePathForVariant(String? variant) {
    if (variant == null || variant.isEmpty) {
      return imagePath;
    }
    return variantImagePaths[variant] ?? imagePath;
  }

  String? noteImagePathForVariant(String? variant) {
    if (variant == null || variant.isEmpty) {
      return noteImagePath;
    }
    return variantNoteImagePaths[variant] ?? noteImagePath;
  }
}

class ThemeAudio {
  final Map<int, String> tilePreviewAssets;
  final Map<int, String> tileCelebrationAssets;
  final List<String> backgroundMusicAssets;

  const ThemeAudio({
    this.tilePreviewAssets = const <int, String>{},
    this.tileCelebrationAssets = const <int, String>{},
    this.backgroundMusicAssets = const <String>[],
  });

  String? tilePreviewAssetForDigit(int digit) => tilePreviewAssets[digit];

  String? tileCelebrationAssetForDigit(int digit) =>
      tileCelebrationAssets[digit] ?? tilePreviewAssets[digit];
}

class ThemeColours {
  final String? background;
  final String? grid;
  final String? highlight;

  const ThemeColours({this.background, this.grid, this.highlight});
}

class ThemeTypography {
  final String? fontFamily;

  const ThemeTypography({this.fontFamily});
}

class ThemePackDescriptor {
  final String id;
  final int version;
  final String downloadUrl;
  final String sha256;
  final int fileSizeBytes;
  final int minimumAppBuild;
  final String? productId;

  const ThemePackDescriptor({
    required this.id,
    required this.version,
    required this.downloadUrl,
    required this.sha256,
    required this.fileSizeBytes,
    required this.minimumAppBuild,
    this.productId,
  });
}
