import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

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
  static const List<String> _hints = <String>[
    "If you're not sure of what goes into a particular tile, you can use Notes as a reminder of what the possibilities are. Select a tile, press Notes, and then select the possible icons that might fit. They will be shown in green. Press Notes again to switch the Notes mode off.",
    'Use a long-press, (hold your finger down for a couple of seconds), to get some information about what something is. Also, try it on a tile that has been filled in.',
    "If your choice leads to two or more tiles being coloured pink, this means you've made a mistake at some point. You have a limited number of auto-corrections that you can use.",
    'Use a long-press on the lock to see what it means.',
    'Press Help to get some information about how to play the game.',
    'Pressing ☰ (top right) opens a drawer that allows you to make some selections.',
    'If the sounds annoy you or you just want to play the game in a quiet environment you can switch the Audio off in the drawer (☰).',
  ];

  bool _ready = false;
  bool _openingGame = false;
  String? _launchError;
  late int _hintIndex;

  @override
  void initState() {
    super.initState();
    _hintIndex = Random().nextInt(_hints.length);
    widget.controller.ready.then((_) {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SudokuScreen(controller: widget.controller),
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
        _launchError = 'Could not open game. Please try again.';
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
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall;
    final introStyle = titleStyle == null
        ? null
        : titleStyle.copyWith(
            fontSize: (titleStyle.fontSize ?? 24) - 6,
            fontWeight: FontWeight.w700,
          );
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
                              'The Angry Grannies bring you',
                              style: introStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ZuDoKu+',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take your time, enjoy each puzzle and keep your mind active.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!widget.controller.hadSavedSessionAtLaunch)
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _openingGame
                                ? null
                                : () => _openGame(startNewGame: false),
                            child: const Text('Play'),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _openingGame
                                    ? null
                                    : () => _openGame(startNewGame: false),
                                child: const Text('Resume'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: _openingGame
                                    ? null
                                    : () => _openGame(startNewGame: true),
                                child: const Text('New game'),
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
                                  'Please wait...',
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
              SizedBox(
                height: 160,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Previous hint',
                          onPressed: () {
                            setState(() {
                              _hintIndex =
                                  (_hintIndex - 1 + _hints.length) %
                                  _hints.length;
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Text(
                            'Hints',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize:
                                  (theme.textTheme.titleSmall?.fontSize ?? 14) +
                                  4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Next hint',
                          onPressed: () {
                            setState(() {
                              _hintIndex = (_hintIndex + 1) % _hints.length;
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          _hints[_hintIndex],
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize:
                                (theme.textTheme.bodySmall?.fontSize ?? 12) + 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
