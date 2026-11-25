import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/theme/downloadable_themes_controller.dart';

class DownloadableThemesScreen extends StatefulWidget {
  final Future<DownloadableThemesController> Function()? createController;
  const DownloadableThemesScreen({super.key, this.createController});

  @override
  State<DownloadableThemesScreen> createState() =>
      _DownloadableThemesScreenState();
}

class _DownloadableThemesScreenState extends State<DownloadableThemesScreen>
    with WidgetsBindingObserver {
  DownloadableThemesController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final controller =
          await (widget.createController ??
              DownloadableThemesController.create)();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controller = controller;
      controller.addListener(_changed);
      setState(() {});
      await controller.initialize();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _controller?.busy == false) {
      unawaited(_controller!.refreshOwnership());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_changed);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return PopScope(
      canPop: controller?.downloading != true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloadable themes'),
          actions: [
            IconButton(
              tooltip: 'Refresh themes',
              icon: const Icon(Icons.refresh),
              onPressed: controller == null || controller.busy
                  ? null
                  : controller.refresh,
            ),
          ],
        ),
        body: _failed
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Themes could not be loaded.'),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            : controller == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Choose a new look for your puzzles.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Each theme is a separate one-time purchase. Theme purchases are separate from Full Version. Download once, then play offline.',
                  ),
                  const SizedBox(height: 12),
                  if (controller.status.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        controller.status,
                        key: const ValueKey('theme-store-status'),
                      ),
                    ),
                  if (controller.busy) ...[
                    LinearProgressIndicator(value: controller.progress),
                    const SizedBox(height: 8),
                    if (controller.downloading)
                      TextButton(
                        onPressed: controller.cancel,
                        child: const Text('Cancel download'),
                      ),
                  ],
                  for (final item in controller.themes.values)
                    _card(context, controller, item),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('restore-theme-purchases'),
                    onPressed: controller.busy || !controller.supported
                        ? null
                        : controller.restore,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore theme purchases'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    DownloadableThemesController controller,
    DownloadableThemeState item,
  ) {
    final id = item.theme.id;
    final installed = item.installed;
    return Card(
      key: ValueKey('theme-card-$id'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(switch (id) {
                  'marine' => Icons.water,
                  'planets' => Icons.public,
                  _ => Icons.radio_button_checked,
                }),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.theme.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.previewPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.file(
                  File(item.previewPath!),
                  height: 160,
                  semanticLabel: '${item.theme.name} tile preview',
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Text(item.theme.description),
            const SizedBox(height: 8),
            Text(
              installed != null
                  ? 'Installed • v${installed.version}'
                  : item.owned
                  ? 'Purchased'
                  : item.descriptor == null
                  ? 'Not available yet'
                  : item.product?.price ?? 'Purchase temporarily unavailable',
            ),
            if (item.descriptor != null)
              Text(
                'Download: ${(item.descriptor!.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              ),
            if (item.error != null)
              Text(
                item.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (installed != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final tile in installed.tiles)
                    Image.file(
                      File(tile.imagePath),
                      width: 56,
                      height: 56,
                      semanticLabel: tile.accessibilityLabel,
                      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (installed != null) ...[
                  FilledButton(
                    key: ValueKey('use-theme-$id'),
                    onPressed: controller.canUse(id)
                        ? () => Navigator.of(context).pop(id)
                        : null,
                    child: const Text('Use in puzzle'),
                  ),
                ],
                if (installed != null || item.damagedInstallation) ...[
                  TextButton(
                    key: ValueKey('remove-theme-$id'),
                    onPressed: controller.busy
                        ? null
                        : () async {
                            final remove = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Remove ${item.theme.name}?'),
                                content: const Text(
                                  'Downloaded files will be removed. Your purchase is retained and can be restored.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Keep theme'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            );
                            if (remove == true) await controller.remove(id);
                          },
                    child: const Text('Remove download'),
                  ),
                ] else if (item.owned)
                  FilledButton(
                    key: ValueKey('download-theme-$id'),
                    onPressed: controller.canDownload(id)
                        ? () => controller.download(id)
                        : null,
                    child: Text(
                      item.error == null ? 'Download' : 'Retry download',
                    ),
                  )
                else
                  FilledButton(
                    key: ValueKey('buy-theme-$id'),
                    onPressed: controller.canBuy(id)
                        ? () => controller.buy(id)
                        : null,
                    child: Text(
                      item.product != null && item.descriptor != null
                          ? 'Buy ${item.product!.price}'
                          : 'Not available yet',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
