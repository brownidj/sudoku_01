import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/app_version_service.dart';
import 'package:flutter_app/ui/services/sudoku_new_game_confirmation_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

class LaunchScreen extends StatefulWidget {
  final SudokuController controller;
  final AnimalAssetService animalAssetService;
  final AppVersionService appVersionService;

  const LaunchScreen({
    super.key,
    required this.controller,
    this.animalAssetService = const AnimalAssetService(),
    this.appVersionService = const AppVersionService(),
  });

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool _ready = false;
  bool _openingGame = false;
  String? _launchError;
  String _versionLabel = 'ZuDoKu';
  final SudokuNewGameConfirmationService _newGameConfirmationService =
      const SudokuNewGameConfirmationService();

  @override
  void initState() {
    super.initState();
    _versionLabel = widget.appVersionService.initialDisplayVersion();
    widget.controller.ready.then((_) {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
    widget.appVersionService.loadDisplayVersion().then((label) {
      if (!mounted) {
        return;
      }
      setState(() {
        _versionLabel = label;
      });
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

  Future<void> _confirmAndStartNewGame() {
    return _newGameConfirmationService.confirmAndRun(
      context: context,
      isMounted: () => mounted,
      title: 'Start New Game?',
      message: 'Start a new game?',
      onConfirm: () {
        _openGame(startNewGame: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _versionLabel,
                  key: const ValueKey<String>('launch-version-title'),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "It's harder than you think: engage more parts of your brain and have twice the fun!",
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ClipRRect(
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
                const SizedBox(height: 16),
                Text(
                  'The Angry Grannies Dev Team',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'dev - DayDay',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'dev - SudokuQueen',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'tech advisor - Icy',
                  style: theme.textTheme.bodySmall,
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
                              : _confirmAndStartNewGame,
                          child: const Text('New game'),
                        ),
                      ),
                    ],
                  ),
                if (_openingGame) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Please wait...',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_launchError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _launchError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
