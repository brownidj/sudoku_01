import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryAutumnLeavesOverlay extends StatefulWidget {
  const VictoryAutumnLeavesOverlay({super.key});

  @override
  State<VictoryAutumnLeavesOverlay> createState() =>
      _VictoryAutumnLeavesOverlayState();
}

class _VictoryAutumnLeavesOverlayState extends State<VictoryAutumnLeavesOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _sequenceDuration = Duration(seconds: 8);
  static const double _sequenceSeconds = 8.0;
  static const int _leafCount = 38;
  static const List<Color> _leafColors = <Color>[
    Color(0xFFE65100), // vivid burnt orange
    Color(0xFFC62828), // deep autumn red
    Color(0xFFF9A825), // bright golden amber
    Color(0xFF6D4C41), // earthy umber
    Color(0xFFE64A19), // rich orange-red
    Color(0xFFAD1457), // berry-magenta accent
  ];

  final math.Random _random = math.Random(20260516);
  late final AnimationController _controller;
  late final List<_LeafSpec> _leaves;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _sequenceDuration)
      ..forward();
    _leaves = List<_LeafSpec>.generate(_leafCount, (_) {
      return _LeafSpec(
        x: _random.nextDouble(),
        y: -0.35 - (_random.nextDouble() * 0.65),
        size: (9 + _random.nextDouble() * 15) * 2,
        color: _leafColors[_random.nextInt(_leafColors.length)],
        fallSpeed: 26 + _random.nextDouble() * 34,
        swayAmplitude: 10 + _random.nextDouble() * 24,
        swayFrequency: 0.7 + _random.nextDouble() * 1.1,
        swayPhase: _random.nextDouble() * math.pi * 2,
        rotateXSpeed: -1.8 + _random.nextDouble() * 3.6,
        rotateYSpeed: -2.1 + _random.nextDouble() * 4.2,
        rotateZSpeed: -1.4 + _random.nextDouble() * 2.8,
        rotatePhase: _random.nextDouble() * math.pi * 2,
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
          key: const ValueKey<String>('victory-autumn-leaves-overlay'),
          painter: _VictoryAutumnLeavesPainter(
            progress: _controller.value,
            leaves: _leaves,
          ),
        );
      },
    );
  }
}

class _LeafSpec {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double fallSpeed;
  final double swayAmplitude;
  final double swayFrequency;
  final double swayPhase;
  final double rotateXSpeed;
  final double rotateYSpeed;
  final double rotateZSpeed;
  final double rotatePhase;

  const _LeafSpec({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.swayPhase,
    required this.rotateXSpeed,
    required this.rotateYSpeed,
    required this.rotateZSpeed,
    required this.rotatePhase,
  });
}

class _VictoryAutumnLeavesPainter extends CustomPainter {
  final double progress;
  final List<_LeafSpec> leaves;

  const _VictoryAutumnLeavesPainter({
    required this.progress,
    required this.leaves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final seconds =
        progress * _VictoryAutumnLeavesOverlayState._sequenceSeconds;
    for (final leaf in leaves) {
      final startX = size.width * leaf.x;
      final startY = size.height * leaf.y;
      final y =
          _wrap(startY + (leaf.fallSpeed * seconds), size.height + 140) - 70;
      final x =
          startX +
          leaf.swayAmplitude *
              math.sin((seconds * leaf.swayFrequency) + leaf.swayPhase);

      final rx = leaf.rotatePhase + (seconds * leaf.rotateXSpeed);
      final ry = leaf.rotatePhase * 0.9 + (seconds * leaf.rotateYSpeed);
      final rz = leaf.rotatePhase * 1.1 + (seconds * leaf.rotateZSpeed);
      final alpha = (0.58 + 0.35 * math.sin(ry).abs())
          .clamp(0.0, 1.0)
          .toDouble();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rz);
      canvas.transform(
        (Matrix4.identity()
              ..setEntry(3, 2, 0.003)
              ..rotateX(rx)
              ..rotateY(ry))
            .storage,
      );
      _drawLeaf(canvas, leaf.size, leaf.color.withValues(alpha: alpha));
      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double size, Color color) {
    final w = size;
    final h = size * 1.45;
    final path = Path()
      ..moveTo(0, -h * 0.5)
      ..quadraticBezierTo(w * 0.45, -h * 0.2, w * 0.42, h * 0.1)
      ..quadraticBezierTo(w * 0.3, h * 0.42, 0, h * 0.5)
      ..quadraticBezierTo(-w * 0.3, h * 0.42, -w * 0.42, h * 0.1)
      ..quadraticBezierTo(-w * 0.45, -h * 0.2, 0, -h * 0.5)
      ..close();
    final fill = Paint()..color = color;
    final glow = Paint()
      ..color = color.withValues(alpha: color.a * 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.6);
    canvas.drawPath(path, glow);
    canvas.drawPath(path, fill);

    final midVein = Paint()
      ..color = const Color(0xFF4E342E).withValues(alpha: color.a * 0.78)
      ..strokeWidth = (size * 0.06).clamp(1.8, 3.2)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -h * 0.44), Offset(0, h * 0.44), midVein);

    final sideVein = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: color.a * 0.65)
      ..strokeWidth = (size * 0.032).clamp(1.1, 2.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final levels = <double>[-0.22, -0.08, 0.08, 0.22];
    for (final t in levels) {
      final y = h * t;
      canvas.drawLine(
        Offset(0, y),
        Offset(w * 0.3, y - h * 0.12 * (t.sign == 0 ? 1 : t.sign)),
        sideVein,
      );
      canvas.drawLine(
        Offset(0, y),
        Offset(-w * 0.3, y - h * 0.12 * (t.sign == 0 ? 1 : t.sign)),
        sideVein,
      );
    }
  }

  double _wrap(double value, double period) {
    if (period <= 0) return 0;
    final mod = value % period;
    return mod < 0 ? mod + period : mod;
  }

  @override
  bool shouldRepaint(covariant _VictoryAutumnLeavesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.leaves != leaves;
  }
}
