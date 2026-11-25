import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/downloadable_theme_catalog.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';
import 'package:flutter_app/ui/theme/theme_purchase_gateway.dart';
import 'package:flutter_app/ui/theme/theme_storage_paths.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DownloadableThemeState {
  final DownloadableTheme theme;
  MarinePilotDescriptor? descriptor;
  ThemeDefinition? installed;
  ThemeStoreProduct? product;
  String? previewPath;
  bool owned = false;
  bool damagedInstallation = false;
  String? error;
  DownloadableThemeState(this.theme);
}

/// Purchase completion and installation are independent: a failed download
/// keeps the verified purchase, so retry never initiates a second payment.
class DownloadableThemesController extends ChangeNotifier {
  final ThemePurchaseGateway purchases;
  final Map<String, MarineThemePackPilot> delivery;
  final Map<String, DownloadableThemeState> themes = {
    for (final theme in DownloadableTheme.all)
      theme.id: DownloadableThemeState(theme),
  };
  StreamSubscription<void>? _purchaseSubscription;
  StreamSubscription<AppleThemePackProgress>? _progressSubscription;
  bool busy = false;
  bool downloading = false;
  bool supported = false;
  bool configured = false;
  bool _disposed = false;
  bool _ownershipRefreshRequested = false;
  String? activeId;
  String status = '';
  double? progress;

  DownloadableThemesController({
    required this.purchases,
    required this.delivery,
  });

  static Future<DownloadableThemesController> create() async {
    final paths = await ThemeStoragePaths.applicationSupport();
    final info = await PackageInfo.fromPlatform();
    final build = int.tryParse(info.buildNumber);
    if (build == null) throw StateError('Unable to determine app version.');
    const purchases = ThemePurchaseGateway();
    final native = AppleThemePackDelivery();
    return DownloadableThemesController(
      purchases: purchases,
      delivery: {
        for (final theme in DownloadableTheme.all)
          theme.id: MarineThemePackPilot(
            delivery: native,
            storagePaths: paths,
            appBuild: build,
            themeId: theme.id,
            expectedProductId: theme.productId,
            hasEntitlement: () => purchases.owns(theme.productId),
          ),
      },
    );
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    _purchaseSubscription ??= purchases.changes.listen(
      (_) {
        if (busy) {
          _ownershipRefreshRequested = true;
        } else {
          unawaited(refreshOwnership());
        }
      },
      onError: (Object _) {
        /* Explicit refresh/restore remains available. */
      },
    );
    _progressSubscription ??= delivery.values.first.delivery.progress.listen(
      (event) {
        if (busy && event.assetPackId == activeId) {
          progress = event.fraction;
          _changed();
        }
      },
      onError: (Object _) {
        /* A missing progress event is not a failed download. */
      },
    );
    await refresh();
  }

  Future<void> refreshOwnership() async {
    for (final item in themes.values) {
      try {
        item.owned = await purchases.owns(item.theme.productId);
      } catch (_) {
        item.owned = false;
      }
    }
    _changed();
  }

  Future<void> refresh() => _run(null, 'Checking available themes…', () async {
    final configuration = await delivery.values.first.delivery
        .getConfiguration();
    supported = configuration.supported;
    configured = configuration.configured;
    for (final item in themes.values) {
      item.error = null;
      item.damagedInstallation = false;
      try {
        item.installed = await delivery[item.theme.id]!.loadInstalled();
      } catch (_) {
        item.installed = null;
        item.damagedInstallation = true;
        item.error =
            'Installed files could not be verified. Remove and download this theme again.';
      }
    }
    await refreshOwnership();
    if (!supported || !configured) {
      status = !supported
          ? 'Theme downloads require iOS 26 or later.'
          : 'Theme downloads are temporarily unavailable.';
      return;
    }
    try {
      final products = await purchases.products(
        DownloadableTheme.all.map((theme) => theme.productId).toSet(),
      );
      for (final item in themes.values) {
        item.product = null;
        for (final product in products) {
          if (product.id == item.theme.productId) item.product = product;
        }
      }
    } catch (_) {
      for (final item in themes.values) {
        item.product = null;
      }
      status =
          'The App Store is unavailable. You can still use installed themes.';
    }
    for (final item in themes.values) {
      try {
        item.descriptor = await delivery[item.theme.id]!.fetchCatalogue();
        if (item.descriptor!.productId != item.theme.productId) {
          item.descriptor = null;
          continue;
        }
        try {
          final path = await delivery[item.theme.id]!.delivery.ensureAvailable(
            assetPackId: 'theme_catalogue',
            relativePath:
                'ThemePreviews/${item.theme.id}_v${item.descriptor!.version}.webp',
          );
          item.previewPath = await File(path).exists() ? path : null;
        } catch (_) {
          item.previewPath = null;
        }
      } catch (_) {
        item.descriptor = null;
      }
    }
    if (status == 'Checking available themes…') status = '';
  });

  bool canBuy(String id) {
    final item = themes[id]!;
    return !busy &&
        supported &&
        configured &&
        !item.owned &&
        item.product != null &&
        item.descriptor != null;
  }

  bool canUse(String id) {
    final item = themes[id]!;
    final installed = item.installed;
    if (busy ||
        item.damagedInstallation ||
        installed == null ||
        installed.id != id) {
      return false;
    }
    // Developer content is separate from paid packs and never grants ownership.
    // A missing store product/catalogue must never turn a paid pack into a pilot.
    if (installed.productId == null) {
      return DownloadableTheme.permitsDeveloperPack(id);
    }
    return installed.productId == item.theme.productId && item.owned;
  }

  bool canDownload(String id) =>
      !busy &&
      supported &&
      configured &&
      themes[id]!.owned &&
      !themes[id]!.damagedInstallation &&
      themes[id]!.descriptor != null &&
      themes[id]!.installed == null;

  Future<void> buy(String id) async {
    if (!canBuy(id)) return;
    await _run(id, 'Waiting for the App Store…', () async {
      final item = themes[id]!;
      final outcome = await purchases.purchase(item.theme.productId);
      item.owned = await purchases.owns(item.theme.productId);
      status = item.owned
          ? 'Purchased. Download ${item.theme.name} when you are ready.'
          : outcome == 'pending'
          ? 'Purchase awaiting approval. Refresh after it is approved.'
          : 'Purchase cancelled.';
    });
  }

  Future<void> restore() => _run(null, 'Restoring theme purchases…', () async {
    if (!supported) {
      status = 'Theme downloads are unavailable on this device.';
      return;
    }
    await purchases.restore();
    await refreshOwnership();
    status = themes.values.any((item) => item.owned)
        ? 'Theme purchases restored.'
        : 'No theme purchases were found for this Apple Account.';
  });

  Future<void> download(String id) async {
    if (!canDownload(id)) return;
    await _run(id, 'Preparing download…', () async {
      final item = themes[id]!;
      item.error = null;
      item.owned = await purchases.owns(item.theme.productId);
      if (!item.owned) {
        throw StateError('Purchase or restore this theme before downloading.');
      }
      item.installed = await delivery[id]!.downloadAndInstall(
        item.descriptor!,
        onStage: (stage) {
          // Delivery stages also apply to Planets and Antique Buttons.
          status = stage.replaceAll('Marine Life', item.theme.name);
          progress = null;
          _changed();
        },
      );
      status = '${item.theme.name} is installed. Choose Use in puzzle.';
    }, isDownload: true);
  }

  Future<void> remove(String id) =>
      _run(id, 'Removing downloaded files…', () async {
        await delivery[id]!.removeInstallation();
        themes[id]!.installed = null;
        themes[id]!.damagedInstallation = false;
        themes[id]!.error = null;
        status = 'Download removed. Your purchase is retained.';
      });

  Future<void> cancel() async {
    if (!downloading || activeId == null) return;
    try {
      await delivery[activeId]!.cancel();
    } catch (_) {
      status = 'Unable to cancel yet. Please try again.';
      _changed();
    }
  }

  Future<void> _run(
    String? id,
    String message,
    Future<void> Function() action, {
    bool isDownload = false,
  }) async {
    if (busy || _disposed) return;
    busy = true;
    downloading = isDownload;
    activeId = id;
    status = message;
    progress = null;
    _changed();
    try {
      await action();
    } catch (error) {
      status = error is MarinePilotCancelledException
          ? 'Download cancelled.'
          : 'Unable to complete this action. Please try again.';
      if (id != null) themes[id]!.error = status;
    } finally {
      if (_ownershipRefreshRequested && !_disposed) {
        _ownershipRefreshRequested = false;
        await refreshOwnership();
      }
      busy = false;
      downloading = false;
      activeId = null;
      progress = null;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_purchaseSubscription?.cancel());
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }
}
