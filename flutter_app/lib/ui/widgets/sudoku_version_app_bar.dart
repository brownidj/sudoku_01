import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/services/app_version_service.dart';

class SudokuVersionAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onVersionTapped;
  final VoidCallback onVersionLongPressed;
  final Duration longPressThreshold;
  final AppVersionService versionService;

  const SudokuVersionAppBar({
    super.key,
    required this.onVersionTapped,
    required this.onVersionLongPressed,
    this.longPressThreshold = const Duration(milliseconds: 1500),
    this.versionService = const AppVersionService(),
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
  String _versionLabel = 'ZuDoKu';

  @override
  void initState() {
    super.initState();
    _versionLabel = widget.versionService.initialDisplayVersion();
    _loadVersionLabel();
  }

  Future<void> _loadVersionLabel() async {
    if (_versionLabel != 'ZuDoKu') {
      return;
    }
    final label = await widget.versionService.loadDisplayVersion();
    if (!mounted) {
      return;
    }
    setState(() {
      _versionLabel = label;
    });
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
      title: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: SizedBox(
            height: kToolbarHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _versionLabel,
                key: const ValueKey<String>('version-title-text'),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
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
