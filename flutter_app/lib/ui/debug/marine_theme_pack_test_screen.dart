import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/theme/apple_theme_pack_delivery.dart';
import 'package:flutter_app/ui/theme/marine_theme_pack_pilot.dart';
import 'package:flutter_app/ui/theme/theme_definition.dart';

class MarineThemePackTestScreen extends StatefulWidget {
  final Future<MarineThemePackPilot> Function()? createPilot;

  const MarineThemePackTestScreen({super.key, this.createPilot});

  @override
  State<MarineThemePackTestScreen> createState() =>
      _MarineThemePackTestScreenState();
}

class _MarineThemePackTestScreenState extends State<MarineThemePackTestScreen> {
  MarineThemePackPilot? _pilot;
  AppleThemePackConfiguration? _configuration;
  MarinePilotDescriptor? _descriptor;
  ThemeDefinition? _installed;
  StreamSubscription<AppleThemePackProgress>? _subscription;
  AppleThemePackProgress? _progress;
  bool _busy = false;
  bool _nativeProgress = false;
  bool _allowExit = false;
  String _status = 'Checking setup…';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) unawaited(_checkSetup());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _run(
    String message,
    Future<void> Function(MarineThemePackPilot) action,
  ) async {
    if (_busy || !kDebugMode) return;
    setState(() {
      _busy = true;
      _status = message;
      _progress = null;
      _allowExit = false;
    });
    try {
      var pilot = _pilot;
      if (pilot == null) {
        pilot = await (widget.createPilot ?? MarineThemePackPilot.create)();
        if (!mounted) return;
        _pilot = pilot;
        _subscription = pilot.delivery.progress.listen(
          (event) {
            if (!mounted ||
                !_busy ||
                !_nativeProgress ||
                (event.assetPackId != 'marine' &&
                    event.assetPackId != 'theme_catalogue')) {
              return;
            }
            setState(() {
              _progress = event;
            });
          },
          onError: (Object error) {
            // A progress-channel problem must not hide the request's outcome.
            if (mounted && _busy) {
              setState(() {
                _status = 'Progress unavailable: $error';
              });
            }
          },
        );
      }
      await action(pilot);
    } catch (error) {
      if (mounted) {
        setState(() {
          _status = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _nativeProgress = false;
        });
      }
    }
  }

  Future<void> _checkSetup() => _run('Checking setup…', (pilot) async {
    final configuration = await pilot.delivery.getConfiguration();
    if (!mounted) return;
    setState(() {
      _configuration = configuration;
    });
    final descriptor = await pilot.cachedCatalogue();
    // Load local files even when Apple delivery is unavailable/offline.
    final installed = await pilot.loadInstalled();
    if (!mounted) return;
    setState(() {
      _descriptor = descriptor;
      _installed = installed;
      _status = !configuration.supported
          ? 'Apple delivery requires iOS 26+ with the native plugin.'
          : !configuration.configured
          ? 'App Group / Apple hosting setup is incomplete. Rebuild after step 3.'
          : 'Ready. Start the local asset server, then fetch the catalogue.';
    });
  });

  Future<void> _fetch() => _run('Fetching pilot catalogue…', (pilot) async {
    _nativeProgress = true;
    final descriptor = await pilot.fetchCatalogue();
    if (!mounted) return;
    setState(() {
      _descriptor = descriptor;
      _status = pilot.usedCachedCatalogue
          ? 'Using cached catalogue. Refresh failed: ${pilot.catalogueWarning}'
          : 'Catalogue ready: Marine Life v${descriptor.version}, '
                '${descriptor.fileSizeBytes} bytes. Free pilot.';
    });
  });

  Future<void> _install() => _run('Preparing installation…', (pilot) async {
    final descriptor = _descriptor!;
    _nativeProgress = true;
    final installed = await pilot.downloadAndInstall(
      descriptor,
      onStage: (stage) {
        if (!mounted) return;
        setState(() {
          _status = stage;
          _nativeProgress = stage.startsWith('Downloading');
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _installed = installed;
      _status =
          'Marine Life v${installed.version} is installed and verified. '
          'The tiles below are loaded from private application storage.';
    });
  });

  Future<void>
  _offline() => _run('Verifying installed files without network access…', (
    pilot,
  ) async {
    final installed = await pilot.loadInstalled();
    if (!mounted) return;
    setState(() {
      _installed = installed;
      _status = installed == null
          ? 'No Marine Life installation was found.'
          : 'Offline verification passed: all nine tiles loaded through the shared loader.';
    });
  });

  Future<void> _cancel() async {
    try {
      await _pilot?.cancel();
      if (mounted && _busy) {
        setState(() {
          _status = 'Cancellation requested…';
          _allowExit = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _status = 'Cancellation failed: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final canDownload =
        !_busy &&
        _configuration?.configured == true &&
        _configuration?.supported == true;
    final installed = _installed;
    return PopScope(
      canPop: !_busy || _allowExit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Marine Life pack test')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Developer pilot • Free • No Full Version unlock needed',
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure Apple’s local HTTPS asset server and the device’s '
              'Background Assets URL override before downloading. '
              'This screen tests delivery, installation and tile loading; '
              'game theme selection comes with the theme browser.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              'Build: ${_pilot?.appBuild ?? "—"}\n'
              'Apple supported: ${_configuration?.supported ?? false}\n'
              'App Group configured: ${_configuration?.configured ?? false}',
            ),
            const SizedBox(height: 12),
            SelectableText(_status, key: const ValueKey('marine-pilot-status')),
            if (_busy) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _nativeProgress ? _progress?.fraction : null,
              ),
              if (_progress != null && _nativeProgress)
                Text(
                  '${_progress!.assetPackId}: ${_progress!.stage.name} '
                  '${_progress!.bytesReceived}/${_progress!.totalBytes}',
                ),
              const Text(
                'Use Cancel to stop the operation and enable leaving this screen.',
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : _checkSetup,
                  child: const Text('Check setup'),
                ),
                FilledButton(
                  onPressed: canDownload ? _fetch : null,
                  child: const Text('Fetch catalogue'),
                ),
                FilledButton(
                  onPressed: canDownload && _descriptor != null
                      ? _install
                      : null,
                  child: const Text('Download and install'),
                ),
                OutlinedButton(
                  onPressed: !_busy && _pilot != null ? _offline : null,
                  child: const Text('Verify offline'),
                ),
                OutlinedButton(
                  onPressed: _busy ? _cancel : null,
                  child: const Text('Cancel'),
                ),
                OutlinedButton(
                  onPressed: !_busy && _pilot != null
                      ? () => _run('Removing installed pilot…', (pilot) async {
                          await pilot.removeInstallation();
                          if (mounted) {
                            setState(() {
                              _installed = null;
                              _status =
                                  'Pilot removed. It can be installed again.';
                            });
                          }
                        })
                      : null,
                  child: const Text('Remove installed pilot'),
                ),
                OutlinedButton(
                  onPressed: canDownload && installed != null
                      ? () => _run('Removing Apple delivery copy…', (
                          pilot,
                        ) async {
                          await pilot.removeDeliveryCopy();
                          if (mounted) {
                            setState(() {
                              _status =
                                  'Apple delivery copy removed. Installed game files retained.';
                            });
                          }
                        })
                      : null,
                  child: const Text('Remove Apple delivery copy'),
                ),
              ],
            ),
            if (installed != null) ...[
              const SizedBox(height: 20),
              Text(
                '${installed.displayName} — installed v${installed.version}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.78,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  for (final tile in installed.tiles)
                    Column(
                      children: [
                        Expanded(
                          child: Image.file(
                            File(tile.imagePath),
                            fit: BoxFit.contain,
                            semanticLabel: tile.accessibilityLabel,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        Text(
                          tile.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
