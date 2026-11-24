import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppleThemePackConfiguration {
  final bool supported;
  final bool configured;

  const AppleThemePackConfiguration({
    required this.supported,
    required this.configured,
  });
}

class AppleAssetPack {
  final String id;
  // Apple's delivery version is distinct from the theme's content version.
  final int version;
  final int downloadBytes;

  const AppleAssetPack({
    required this.id,
    required this.version,
    required this.downloadBytes,
  });

  factory AppleAssetPack.fromMap(Map<Object?, Object?> map) => AppleAssetPack(
    id: map['id'] as String,
    version: map['version'] as int,
    downloadBytes: map['downloadBytes'] as int,
  );
}

enum AppleThemePackStage {
  waiting,
  paused,
  downloading,
  available,
  cancelled,
  failed,
}

class AppleThemePackProgress {
  final String assetPackId;
  final AppleThemePackStage stage;
  final int bytesReceived;
  final int totalBytes;

  const AppleThemePackProgress({
    required this.assetPackId,
    required this.stage,
    required this.bytesReceived,
    required this.totalBytes,
  });

  double? get fraction =>
      totalBytes > 0 ? (bytesReceived / totalBytes).clamp(0.0, 1.0) : null;

  factory AppleThemePackProgress.fromMap(Map<Object?, Object?> map) =>
      AppleThemePackProgress(
        assetPackId: map['assetPackId'] as String,
        stage: AppleThemePackStage.values.byName(map['stage'] as String),
        bytesReceived: map['bytesReceived'] as int,
        totalBytes: map['totalBytes'] as int,
      );
}

/// Delivery only. "available" means Apple has provided a local file; it does
/// not mean the ZIP has been validated/installed or the player owns a paid pack.
/// Callers must run shared integrity/entitlement checks before installation.
class AppleThemePackDelivery {
  static const methodChannelName =
      'org.topository.animalsudoku/apple_theme_packs';
  static const progressChannelName = '$methodChannelName/progress';

  final MethodChannel methodChannel;
  final EventChannel eventChannel;
  final TargetPlatform? platformOverride;
  Stream<AppleThemePackProgress>? _progress;

  AppleThemePackDelivery({
    this.methodChannel = const MethodChannel(methodChannelName),
    this.eventChannel = const EventChannel(progressChannelName),
    this.platformOverride,
  });

  Future<AppleThemePackConfiguration> getConfiguration() async {
    if (kIsWeb ||
        (platformOverride ?? defaultTargetPlatform) != TargetPlatform.iOS) {
      return const AppleThemePackConfiguration(
        supported: false,
        configured: false,
      );
    }
    try {
      final map = await methodChannel.invokeMapMethod<String, Object?>(
        'getConfiguration',
      );
      return AppleThemePackConfiguration(
        supported: map?['supported'] == true,
        configured: map?['configured'] == true,
      );
    } on MissingPluginException {
      return const AppleThemePackConfiguration(
        supported: false,
        configured: false,
      );
    }
  }

  Future<List<AppleAssetPack>> listAssetPacks() async {
    final list = await methodChannel.invokeListMethod<Object?>(
      'listAssetPacks',
    );
    return List.unmodifiable([
      for (final item in list ?? const <Object?>[])
        AppleAssetPack.fromMap(item as Map<Object?, Object?>),
    ]);
  }

  /// Subscribe before requesting a download. Multiple callers share one native
  /// event subscription; events are tagged by assetPackId. Unsubscribing does
  /// not cancel a background transfer. Use cancelDownload explicitly.
  Stream<AppleThemePackProgress> get progress =>
      _progress ??= eventChannel.receiveBroadcastStream().map(
        (event) =>
            AppleThemePackProgress.fromMap(event as Map<Object?, Object?>),
      );

  Future<String> ensureAvailable({
    required String assetPackId,
    required String relativePath,
  }) => _path('ensureAvailable', assetPackId, relativePath);

  /// Resolves an already-downloaded file without initiating a download.
  Future<String> localPath({
    required String assetPackId,
    required String relativePath,
  }) => _path('localPath', assetPackId, relativePath);

  Future<void> cancelDownload(String assetPackId) =>
      methodChannel.invokeMethod<void>('cancelDownload', {
        'assetPackId': _validId(assetPackId),
      });

  /// Removes Apple's delivery copy only. Never call this before the shared
  /// installer has successfully committed the private game installation.
  Future<void> removeAssetPack(String assetPackId) =>
      methodChannel.invokeMethod<void>('removeAssetPack', {
        'assetPackId': _validId(assetPackId),
      });

  Future<String> _path(String method, String id, String path) async {
    _validId(id);
    if (path.isEmpty ||
        path.contains('\\') ||
        path.contains(':') ||
        path
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw ArgumentError.value(
        path,
        'relativePath',
        'Expected a safe relative path.',
      );
    }
    final result = await methodChannel.invokeMethod<String>(method, {
      'assetPackId': id,
      'relativePath': path,
    });
    if (result == null || result.isEmpty) {
      throw StateError('Apple delivery returned no local asset path.');
    }
    return result;
  }

  String _validId(String value) {
    if (!RegExp(r'^[a-z][a-z0-9_-]{2,63}$').hasMatch(value)) {
      throw ArgumentError.value(value, 'assetPackId', 'Invalid asset-pack ID.');
    }
    return value;
  }
}
