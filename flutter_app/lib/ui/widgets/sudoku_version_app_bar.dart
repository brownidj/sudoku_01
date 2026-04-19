import 'dart:async';

import 'package:flutter/material.dart';

class SudokuVersionAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onNewGamePressed;
  final VoidCallback onVersionTapped;
  final VoidCallback onVersionLongPressed;
  final Duration longPressThreshold;

  const SudokuVersionAppBar({
    super.key,
    required this.onNewGamePressed,
    required this.onVersionTapped,
    required this.onVersionLongPressed,
    this.longPressThreshold = const Duration(milliseconds: 1500),
  });

  @override
  State<SudokuVersionAppBar> createState() => _SudokuVersionAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SudokuVersionAppBarState extends State<SudokuVersionAppBar> {
  Timer? _longPressTimer;
  bool _versionPressActive = false;
  bool _longPressTriggered = false;
  String _versionLabel = 'ZuDoKu+';

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
    const sideSlotWidth = 132.0;
    return AppBar(
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            SizedBox(
              width: sideSlotWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  key: const ValueKey<String>('appbar-new-game-chip'),
                  onPressed: widget.onNewGamePressed,
                  label: Text(
                    'New Game',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize:
                          (Theme.of(context).textTheme.labelLarge?.fontSize ??
                              14) +
                          2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
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
                          (Theme.of(context).textTheme.titleLarge?.fontSize ??
                              22) +
                          4,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: sideSlotWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Builder(
                  builder: (context) => IconButton(
                    key: const ValueKey<String>('appbar-menu-button'),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu),
                    tooltip:
                        'Press this to open a drawer. Use the drawer menu to change animals and style.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }
}
