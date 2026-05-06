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
  static const List<String> _celebrationPrefixes = <String>[
    'Well done!',
    'Great job!',
    'You nailed it!',
    'Brilliant finish!',
    'Excellent work!',
    'Nice one!',
    'You did it!',
    'Superb effort!',
    'Proud of you!',
    'Keep it up!',
    'Amazing work!',
    'Fantastic job!',
    'Perfect solve!',
    'Strong finish!',
    'Clever thinking!',
    'Sweet success!',
    'Top effort!',
    'Masterful play!',
    'Winner mindset!',
    'Outstanding result!',
  ];

  late final AnimationController _swingController;
  late final Animation<double> _swingAngle;
  final math.Random _random = math.Random();
  late String _message;

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
    _message = _buildMessage();
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VictoryMascotOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assetPath != oldWidget.assetPath && widget.assetPath != null) {
      _message = _buildMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetPath == null || widget.centerY == null) {
      return const SizedBox.shrink();
    }

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
                    _message,
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

  String _buildMessage() {
    final prefix =
        _celebrationPrefixes[_random.nextInt(_celebrationPrefixes.length)];
    return '$prefix Play again!';
  }
}
