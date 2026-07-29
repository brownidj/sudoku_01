import 'dart:convert';

import 'package:flutter_app/ui/theme/theme_pack_errors.dart';

class ThemeManifest {
  static const supportedSchemaVersion = 1;

  final int schemaVersion;
  final String themeId;
  final int themeVersion;
  final String displayName;
  final int tileCount;
  final List<ThemeManifestTile> tiles;
  final String previewPath;
  final ThemeManifestAudio audio;
  final ThemeManifestColours colours;
  final int? minimumAppBuild;
  final Map<String, String> checksums;

  const ThemeManifest({
    required this.schemaVersion,
    required this.themeId,
    required this.themeVersion,
    required this.displayName,
    required this.tileCount,
    required this.tiles,
    required this.previewPath,
    required this.audio,
    required this.colours,
    required this.minimumAppBuild,
    required this.checksums,
  });

  factory ThemeManifest.fromJsonText(String text) {
    final decoded = _decodeJson(text);
    if (decoded is! Map<String, dynamic>) {
      throw const InvalidThemeManifestException('Manifest must be an object.');
    }
    return ThemeManifest.fromJson(decoded);
  }

  factory ThemeManifest.fromJson(Map<String, dynamic> json) {
    final schemaVersion = _requiredInt(json, 'schema_version');
    if (schemaVersion != supportedSchemaVersion) {
      throw UnsupportedThemeManifestVersionException(schemaVersion);
    }
    final themeId = _requiredString(json, 'theme_id');
    if (!RegExp(r'^[a-z][a-z0-9_-]{2,63}$').hasMatch(themeId)) {
      throw InvalidThemeManifestException('Invalid theme_id: $themeId');
    }
    final themeVersion = _requiredInt(json, 'theme_version');
    if (themeVersion <= 0) {
      throw const InvalidThemeManifestException(
        'theme_version must be greater than zero.',
      );
    }
    final tileCount = _requiredInt(json, 'tile_count');
    if (tileCount != 9) {
      throw const InvalidThemeManifestException('tile_count must be 9.');
    }
    final tilesRaw = json['tiles'];
    if (tilesRaw is! List || tilesRaw.length != tileCount) {
      throw const InvalidThemeManifestException(
        'tiles must contain exactly tile_count entries.',
      );
    }

    return ThemeManifest(
      schemaVersion: schemaVersion,
      themeId: themeId,
      themeVersion: themeVersion,
      displayName: _requiredString(json, 'display_name'),
      tileCount: tileCount,
      tiles: [
        for (final tileRaw in tilesRaw)
          ThemeManifestTile.fromJson(_asMap(tileRaw, 'tile')),
      ],
      previewPath: _requiredString(json, 'preview_path'),
      audio: ThemeManifestAudio.fromJson(_optionalMap(json['audio'])),
      colours: ThemeManifestColours.fromJson(_optionalMap(json['colours'])),
      minimumAppBuild: json['minimum_app_build'] is int
          ? json['minimum_app_build'] as int
          : null,
      checksums: _parseChecksums(_optionalMap(json['checksums'])),
    );
  }

  Iterable<String> referencedPaths() sync* {
    yield previewPath;
    for (final tile in tiles) {
      yield tile.path;
    }
    yield* audio.referencedPaths();
  }
}

class ThemeManifestTile {
  final String id;
  final String path;
  final String? accessibilityLabel;

  const ThemeManifestTile({
    required this.id,
    required this.path,
    required this.accessibilityLabel,
  });

  factory ThemeManifestTile.fromJson(Map<String, dynamic> json) {
    return ThemeManifestTile(
      id: _requiredString(json, 'id'),
      path: _requiredString(json, 'path'),
      accessibilityLabel: json['accessibility_label'] is String
          ? json['accessibility_label'] as String
          : null,
    );
  }
}

class ThemeManifestAudio {
  final List<ThemeManifestTileAudio> tiles;
  final List<String> music;

  const ThemeManifestAudio({required this.tiles, required this.music});

  factory ThemeManifestAudio.fromJson(Map<String, dynamic> json) {
    final tilesRaw = json['tiles'];
    final musicRaw = json['music'];
    return ThemeManifestAudio(
      tiles: tilesRaw is List
          ? [
              for (final item in tilesRaw)
                ThemeManifestTileAudio.fromJson(_asMap(item, 'audio tile')),
            ]
          : const <ThemeManifestTileAudio>[],
      music: musicRaw is List
          ? [
              for (final item in musicRaw)
                if (item is String) item else _invalidString('music path'),
            ]
          : const <String>[],
    );
  }

  Iterable<String> referencedPaths() sync* {
    for (final tile in tiles) {
      if (tile.longPress != null) yield tile.longPress!;
      if (tile.celebration != null) yield tile.celebration!;
    }
    yield* music;
  }
}

class ThemeManifestTileAudio {
  final int digit;
  final String? longPress;
  final String? celebration;

  const ThemeManifestTileAudio({
    required this.digit,
    required this.longPress,
    required this.celebration,
  });

  factory ThemeManifestTileAudio.fromJson(Map<String, dynamic> json) {
    final digit = _requiredInt(json, 'digit');
    if (digit < 1 || digit > 9) {
      throw const InvalidThemeManifestException(
        'audio tile digit must be 1 through 9.',
      );
    }
    return ThemeManifestTileAudio(
      digit: digit,
      longPress: json['long_press'] is String
          ? json['long_press'] as String
          : null,
      celebration: json['celebration'] is String
          ? json['celebration'] as String
          : null,
    );
  }
}

class ThemeManifestColours {
  final String? background;
  final String? grid;
  final String? highlight;

  const ThemeManifestColours({this.background, this.grid, this.highlight});

  factory ThemeManifestColours.fromJson(Map<String, dynamic> json) {
    return ThemeManifestColours(
      background: json['background'] is String
          ? json['background'] as String
          : null,
      grid: json['grid'] is String ? json['grid'] as String : null,
      highlight: json['highlight'] is String
          ? json['highlight'] as String
          : null,
    );
  }
}

Object? _decodeJson(String text) {
  try {
    return jsonDecode(text);
  } on FormatException catch (error) {
    throw InvalidThemeManifestException('Malformed manifest JSON: $error');
  }
}

Map<String, dynamic> _asMap(Object? value, String fieldName) {
  if (value is Map<String, dynamic>) return value;
  throw InvalidThemeManifestException('$fieldName must be an object.');
}

Map<String, dynamic> _optionalMap(Object? value) {
  if (value == null) return const <String, dynamic>{};
  return _asMap(value, 'optional field');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw InvalidThemeManifestException('Missing or invalid $key.');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw InvalidThemeManifestException('Missing or invalid $key.');
}

String _invalidString(String fieldName) {
  throw InvalidThemeManifestException('$fieldName must be a string.');
}

Map<String, String> _parseChecksums(Map<String, dynamic> json) {
  final checksums = <String, String>{};
  for (final entry in json.entries) {
    final value = entry.value;
    if (value is! String || !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(value)) {
      throw InvalidThemeManifestException(
        'Invalid SHA-256 checksum for ${entry.key}.',
      );
    }
    checksums[entry.key] = value.toLowerCase();
  }
  return Map<String, String>.unmodifiable(checksums);
}
