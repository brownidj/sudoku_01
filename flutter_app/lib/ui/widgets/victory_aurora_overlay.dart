import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryAuroraOverlay extends StatefulWidget {
  const VictoryAuroraOverlay({super.key});

  @override
  State<VictoryAuroraOverlay> createState() => _VictoryAuroraOverlayState();
}

class _VictoryAuroraOverlayState extends State<VictoryAuroraOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          key: const ValueKey<String>('victory-aurora-overlay'),
          painter: _VictoryAuroraPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _VictoryAuroraPainter extends CustomPainter {
  final double progress;

  const _VictoryAuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    _paintRibbon(
      canvas: canvas,
      size: size,
      t: t,
      verticalOffset: 0.22,
      amplitude: 34,
      thickness: 120,
      colors: const <Color>[
        Color(0x44E9DFC9), // champagne
        Color(0x33B9D7D9), // pale teal
        Color(0x22F4F1E8),
      ],
      drift: 0.9,
    );
    _paintRibbon(
      canvas: canvas,
      size: size,
      t: t + 1.4,
      verticalOffset: 0.36,
      amplitude: 28,
      thickness: 100,
      colors: const <Color>[
        Color(0x3388AEBF), // muted silver-blue
        Color(0x22E4DCCB),
        Color(0x1FD6ECEE),
      ],
      drift: 0.7,
    );
    _paintRibbon(
      canvas: canvas,
      size: size,
      t: t + 2.1,
      verticalOffset: 0.50,
      amplitude: 22,
      thickness: 80,
      colors: const <Color>[
        Color(0x2271A3A9),
        Color(0x1FE7E3D2),
        Color(0x1ABDD9DB),
      ],
      drift: 0.5,
    );
  }

  void _paintRibbon({
    required Canvas canvas,
    required Size size,
    required double t,
    required double verticalOffset,
    required double amplitude,
    required double thickness,
    required List<Color> colors,
    required double drift,
  }) {
    final centerY = size.height * verticalOffset;
    final dx = size.width * 0.08 * math.sin(t * drift);
    final p = Path();
    p.moveTo(-40 + dx, centerY);
    for (double x = -40; x <= size.width + 40; x += 16) {
      final wave =
          math.sin((x / size.width) * math.pi * 2 + t * 0.9) * amplitude;
      p.lineTo(x + dx, centerY + wave);
    }
    for (double x = size.width + 40; x >= -40; x -= 16) {
      final wave =
          math.sin((x / size.width) * math.pi * 2 + t * 0.9) * amplitude;
      p.lineTo(x + dx, centerY + wave + thickness);
    }
    p.close();

    final bounds = Rect.fromLTWH(0, centerY - amplitude, size.width, thickness + amplitude * 2);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(bounds)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(p, fill);
  }

  @override
  bool shouldRepaint(covariant _VictoryAuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
