import 'dart:async';

import 'package:flutter/material.dart';

class SudokuVersionAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onVersionTapped;
  final VoidCallback onVersionLongPressed;
  final Duration longPressThreshold;

  const SudokuVersionAppBar({
    super.key,
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
    return AppBar(
      automaticallyImplyLeading: false,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: SizedBox(
          height: kToolbarHeight,
          child: Center(
            child: Text(
              _versionLabel,
              key: const ValueKey<String>('version-title-text'),
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
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
    );
  }
}
