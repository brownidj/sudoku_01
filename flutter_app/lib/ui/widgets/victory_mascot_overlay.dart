import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryMascotOverlay extends StatefulWidget {
  final String? assetPath;
  final double? centerY;

  const VictoryMascotOverlay({
    super.key,
    required this.assetPath,
    required this.centerY,
  });

  @override
  State<VictoryMascotOverlay> createState() => _VictoryMascotOverlayState();
}

class _VictoryMascotOverlayState extends State<VictoryMascotOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swingController;
  late final Animation<double> _swingAngle;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _swingAngle =
        Tween<double>(
          begin: -10 * math.pi / 180,
          end: 10 * math.pi / 180,
        ).animate(
          CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetPath == null || widget.centerY == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - 96) / 2;
        final top = widget.centerY! - 48 - 115;
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: 96,
              height: 96,
              child: AnimatedBuilder(
                animation: _swingController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _swingAngle.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  widget.assetPath!,
                  key: const ValueKey<String>('victory-cartoon-image'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: top + 96,
              child: const Center(
                child: Text(
                  "Play again! Play again!''",
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontFamilyFallback: <String>['Helvetica', 'sans-serif'],
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
