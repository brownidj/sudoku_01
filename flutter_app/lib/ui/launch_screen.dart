import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/widgets/launch_screen_hint_carousel.dart';

class LaunchScreen extends StatefulWidget {
  final SudokuController controller;
  final AnimalAssetService animalAssetService;

  const LaunchScreen({
    super.key,
    required this.controller,
    this.animalAssetService = const AnimalAssetService(),
  });

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool _ready = false;
  bool _openingGame = false;
  String? _launchError;
  late int _hintIndex;

  @override
  void initState() {
    super.initState();
    _hintIndex = ScreenshotMode.enabled ? 0 : Random().nextInt(9);
    widget.controller.ready.then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _ready = true;
      });
      if (ScreenshotMode.enabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          if (ScreenshotMode.isHome) {
            ScreenshotMode.reportReady();
            return;
          }
          _startGame();
        });
      }
    });
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => SudokuScreen(controller: widget.controller),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _openGame({required bool startNewGame}) async {
    if (_openingGame) {
      return;
    }
    setState(() {
      _openingGame = true;
      _launchError = null;
    });
    try {
      if (!_ready) {
        await widget.controller.ready;
      }
      if (!mounted) {
        return;
      }
      if (startNewGame) {
        widget.controller.onNewGame();
      }
      final contentMode = widget.controller.state.contentMode;
      if (contentMode != 'numbers') {
        await widget.animalAssetService.load();
      }
      if (!mounted) {
        return;
      }
      _startGame();
    } catch (error, stackTrace) {
      debugPrint('Failed to open game: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _launchError = UiStrings.launchErrorOpenGame(context);
      });
    } finally {
      if (mounted) {
        setState(() {
          _openingGame = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hints = UiStrings.launchHints(context);
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall;
    final introStyle = titleStyle?.copyWith(
      fontSize: (titleStyle.fontSize ?? 24) - 6,
      fontWeight: FontWeight.w700,
    );
    final showSavedSessionActions =
        !ScreenshotMode.enabled && widget.controller.hadSavedSessionAtLaunch;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              'assets/images/icons/super_granny.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Column(
                          children: [
                            Text(
                              UiStrings.launchTitlePrefix(context),
                              style: introStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UiStrings.launchTitle(context),
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        UiStrings.launchSubtitle(context),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!showSavedSessionActions)
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            key: const ValueKey<String>('launch-play-button'),
                            onPressed: _openingGame
                                ? null
                                : () => _openGame(startNewGame: false),
                            child: Text(UiStrings.actionPlay(context)),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                key: const ValueKey<String>(
                                  'launch-resume-button',
                                ),
                                onPressed: _openingGame
                                    ? null
                                    : () => _openGame(startNewGame: false),
                                child: Text(UiStrings.actionResume(context)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                key: const ValueKey<String>(
                                  'launch-new-game-button',
                                ),
                                onPressed: _openingGame
                                    ? null
                                    : () => _openGame(startNewGame: true),
                                child: Text(
                                  UiStrings.actionStartNewGame(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: _openingGame
                              ? Text(
                                  UiStrings.actionPleaseWait(context),
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                )
                              : (_launchError != null
                                    ? Text(
                                        _launchError!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                        textAlign: TextAlign.center,
                                      )
                                    : null),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              LaunchScreenHintCarousel(
                hints: hints,
                hintIndex: _hintIndex,
                onHintIndexChanged: (hintIndex) {
                  setState(() {
                    _hintIndex = hintIndex;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
