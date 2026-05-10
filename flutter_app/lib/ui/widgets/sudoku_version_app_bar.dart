import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/long_press_tooltip.dart';

class SudokuVersionAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onVersionTapped;
  final VoidCallback onVersionLongPressed;
  final bool audioEnabled;
  final bool showMusicControls;
  final bool backgroundMusicEnabled;
  final VoidCallback? onMusicControlSingleTap;
  final VoidCallback? onMusicControlDoubleTap;
  final VoidCallback? onPreviousTrackTapped;
  final VoidCallback? onNextTrackTapped;
  final Duration longPressThreshold;

  const SudokuVersionAppBar({
    super.key,
    required this.onVersionTapped,
    required this.onVersionLongPressed,
    this.audioEnabled = true,
    this.showMusicControls = true,
    this.backgroundMusicEnabled = false,
    this.onMusicControlSingleTap,
    this.onMusicControlDoubleTap,
    this.onPreviousTrackTapped,
    this.onNextTrackTapped,
    this.longPressThreshold = const Duration(milliseconds: 1500),
  });

  @override
  State<SudokuVersionAppBar> createState() => _SudokuVersionAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SudokuVersionAppBarState extends State<SudokuVersionAppBar> {
  static const String _musicControlsTooltip =
      'Press once to turn the background music off or twice, in quick succession to turn it on. Previous and Next retreat or advance the background music tune.';
  Timer? _longPressTimer;
  bool _versionPressActive = false;
  bool _longPressTriggered = false;
  String _versionLabel = 'SuDoKu Playtime';

  @override
  void initState() {
    super.initState();
  }

  void _handleTapDown(TapDownDetails _) {
    _longPressTimer?.cancel();
    _versionPressActive = true;
    _longPressTriggered = false;
    _longPressTimer = Timer(widget.longPressThreshold, () {
      if (!_versionPressActive || _longPressTriggered) {
        return;
      }
      _longPressTriggered = true;
      widget.onVersionLongPressed();
    });
  }

  void _handleTapUp(TapUpDetails _) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    final shouldHandleAsTap = _versionPressActive && !_longPressTriggered;
    _versionPressActive = false;
    if (shouldHandleAsTap) {
      widget.onVersionTapped();
    }
  }

  void _handleTapCancel() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _versionPressActive = false;
    _longPressTriggered = false;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lighterDisabledMusicColor = Color.lerp(
      theme.disabledColor,
      theme.colorScheme.surface,
      0.45,
    );
    final musicColor = widget.backgroundMusicEnabled
        ? null
        : lighterDisabledMusicColor;
    return AppBar(
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: Text(
                    _versionLabel,
                    key: const ValueKey<String>('version-title-text'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                          22,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.audioEnabled && widget.showMusicControls) ...[
                    _MusicGlyphButton(
                      key: const ValueKey<String>('appbar-music-prev-button'),
                      text: '<',
                      fontSize: 30,
                      color: musicColor,
                      onTap: widget.backgroundMusicEnabled
                          ? widget.onPreviousTrackTapped
                          : null,
                      longPressMessage: _musicControlsTooltip,
                    ),
                    const SizedBox(width: 6),
                    _MusicGlyphButton(
                      key: const ValueKey<String>('appbar-music-note-text'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                          'assets/images/icons/bg_music.png',
                          width: 36,
                          height: 36,
                          color: musicColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      color: musicColor,
                      onTap: widget.onMusicControlSingleTap,
                      onDoubleTap: widget.onMusicControlDoubleTap,
                      longPressMessage: _musicControlsTooltip,
                    ),
                    const SizedBox(width: 6),
                    _MusicGlyphButton(
                      key: const ValueKey<String>('appbar-music-next-button'),
                      text: '>',
                      fontSize: 30,
                      color: musicColor,
                      onTap: widget.backgroundMusicEnabled
                          ? widget.onNextTrackTapped
                          : null,
                      longPressMessage: _musicControlsTooltip,
                    ),
                    const SizedBox(width: 20),
                  ],
                  Builder(
                    builder: (context) => IconButton(
                      key: const ValueKey<String>('appbar-menu-button'),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                      tooltip:
                          'Press this to open a drawer. Use the drawer menu to change animals and style.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
    );
  }
}

class _MusicGlyphButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final String longPressMessage;
  final EdgeInsets padding;
  final double fontSize;

  const _MusicGlyphButton({
    super.key,
    this.text,
    this.child,
    this.color,
    this.onTap,
    this.onDoubleTap,
    required this.longPressMessage,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    this.fontSize = 20,
  }) : assert(text != null || child != null);

  @override
  Widget build(BuildContext context) {
    return LongPressTooltip(
      message: longPressMessage,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Padding(
          padding: padding,
          child:
              child ??
              Text(
                text!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
        ),
      ),
    );
  }
}
