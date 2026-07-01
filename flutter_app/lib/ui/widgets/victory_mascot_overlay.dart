import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/ui/ui_strings.dart';

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
  final math.Random _random = math.Random(0);
  late int _messageIndex;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _swingAngle =
        Tween<double>(
          begin: -10 * math.pi / 180,
          end: 10 * math.pi / 180,
        ).animate(
          CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
        );
    if (ScreenshotMode.enabled && ScreenshotMode.isCelebration) {
      _swingController.value = 0.5;
    } else {
      _swingController.repeat(reverse: true);
    }
    _messageIndex = ScreenshotMode.enabled && ScreenshotMode.isCelebration
        ? 0
        : _random.nextInt(20);
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
    final messages = UiStrings.victoryCelebrationMessages(context);
    final message = messages[_messageIndex % messages.length];

    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - 96) / 2;
        final top = widget.centerY! - 48 - 125;
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
              top: top + 96 + 12,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    message,
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
            ),
          ],
        );
      },
    );
  }
}
