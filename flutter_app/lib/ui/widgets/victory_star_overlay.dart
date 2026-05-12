import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryStarOverlay extends StatefulWidget {
  const VictoryStarOverlay({super.key});

  @override
  State<VictoryStarOverlay> createState() => _VictoryStarOverlayState();
}

class _VictoryStarOverlayState extends State<VictoryStarOverlay>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = <Color>[
    Color(0xFFFFD54F),
    Color(0xFFFF8A80),
    Color(0xFF81D4FA),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
  ];
  static const int _starCount = 34;
  final math.Random _random = math.Random();
  late final AnimationController _controller;
  late final List<_StarConfig> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _stars = List<_StarConfig>.generate(_starCount, (_) {
      return _StarConfig(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 18 + _random.nextDouble() * 22,
        color: _colors[_random.nextInt(_colors.length)],
        phase: _random.nextDouble() * math.pi * 2,
        speed: 0.6 + _random.nextDouble() * 1.1,
        fallSpeed: 40 + _random.nextDouble() * 90,
        driftAmplitude: 6 + _random.nextDouble() * 20,
        driftFrequency: 0.8 + _random.nextDouble() * 1.8,
        driftPhase: _random.nextDouble() * math.pi * 2,
      );
    });
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
          key: const ValueKey<String>('victory-star-overlay'),
          painter: _VictoryStarPainter(
            progress: _controller.value,
            stars: _stars,
          ),
        );
      },
    );
  }
}

class _StarConfig {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double phase;
  final double speed;
  final double fallSpeed;
  final double driftAmplitude;
  final double driftFrequency;
  final double driftPhase;

  const _StarConfig({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.phase,
    required this.speed,
    required this.fallSpeed,
    required this.driftAmplitude,
    required this.driftFrequency,
    required this.driftPhase,
  });
}

class _VictoryStarPainter extends CustomPainter {
  final double progress;
  final List<_StarConfig> stars;

  const _VictoryStarPainter({required this.progress, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress * 1.8;
    for (final star in stars) {
      final startX = size.width * star.x;
      final startY = size.height * star.y;
      final cy =
          _wrap(startY + (star.fallSpeed * seconds), size.height + star.size) -
          (star.size / 2);
      final cx =
          startX +
          star.driftAmplitude *
              math.sin((seconds * star.driftFrequency) + star.driftPhase);
      final t = (progress * math.pi * 2 * star.speed) + star.phase;
      final flip = 0.2 + (math.cos(t).abs() * 0.8);
      final opacity = 0.55 + (math.sin(t).abs() * 0.4);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(1.0, flip); // x-axis flip effect
      _drawStar(
        canvas,
        star.size,
        star.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Color color) {
    final outer = size / 2;
    final inner = outer * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i += 1) {
      final isOuter = i.isEven;
      final radius = isOuter ? outer : inner;
      final angle = (-math.pi / 2) + (i * math.pi / 5);
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    final paint = Paint()..color = color;
    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  double _wrap(double value, double period) {
    if (period <= 0) {
      return 0;
    }
    final mod = value % period;
    return mod < 0 ? mod + period : mod;
  }

  @override
  bool shouldRepaint(covariant _VictoryStarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.stars != stars;
  }
}
