import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryCottonOverlay extends StatefulWidget {
  const VictoryCottonOverlay({super.key});

  @override
  State<VictoryCottonOverlay> createState() => _VictoryCottonOverlayState();
}

class _VictoryCottonOverlayState extends State<VictoryCottonOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _sequenceDuration = Duration(seconds: 8);
  static const double _sequenceSeconds = 8.0;
  static const int _clusterCount = 34;
  static const List<Color> _palette = <Color>[
    Color(0xFFFF69B4), // saturated pink
    Color(0xFF4FC3F7), // saturated sky blue
    Color(0xFF9C6DFF), // saturated lavender
    Color(0xFFFFC14D), // saturated apricot
    Color(0xFF4CD97D), // saturated mint
  ];

  final math.Random _random = math.Random(20260515);
  late final AnimationController _controller;
  late final List<_CottonCluster> _clusters;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _sequenceDuration)
      ..forward();
    _clusters = List<_CottonCluster>.generate(_clusterCount, (_) {
      return _CottonCluster(
        x: _random.nextDouble(),
        y: -0.35 - (_random.nextDouble() * 0.65),
        baseRadius: 14 + _random.nextDouble() * 30,
        fallSpeed: 7 + _random.nextDouble() * 16,
        swayAmplitude: 8 + _random.nextDouble() * 18,
        swayFrequency: 0.35 + _random.nextDouble() * 0.65,
        phase: _random.nextDouble() * math.pi * 2,
        color: _palette[_random.nextInt(_palette.length)],
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
          key: const ValueKey<String>('victory-cotton-overlay'),
          painter: _VictoryCottonPainter(
            progress: _controller.value,
            clusters: _clusters,
          ),
        );
      },
    );
  }
}

class _CottonCluster {
  final double x;
  final double y;
  final double baseRadius;
  final double fallSpeed;
  final double swayAmplitude;
  final double swayFrequency;
  final double phase;
  final Color color;

  const _CottonCluster({
    required this.x,
    required this.y,
    required this.baseRadius,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.phase,
    required this.color,
  });
}

class _VictoryCottonPainter extends CustomPainter {
  final double progress;
  final List<_CottonCluster> clusters;

  const _VictoryCottonPainter({required this.progress, required this.clusters});

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress * _VictoryCottonOverlayState._sequenceSeconds;
    for (final cluster in clusters) {
      final startX = size.width * cluster.x;
      final startY = size.height * cluster.y;
      final y =
          _wrap(startY + cluster.fallSpeed * seconds, size.height + 140) - 70;
      final x =
          startX +
          cluster.swayAmplitude *
              math.sin((seconds * cluster.swayFrequency) + cluster.phase);
      _paintCottonCluster(canvas, Offset(x, y), cluster);
    }
  }

  void _paintCottonCluster(
    Canvas canvas,
    Offset center,
    _CottonCluster cluster,
  ) {
    final lobeOffsets = <Offset>[
      const Offset(-0.55, -0.1),
      const Offset(-0.15, -0.35),
      const Offset(0.25, -0.2),
      const Offset(0.6, 0.05),
      const Offset(0.1, 0.28),
      const Offset(-0.35, 0.22),
    ];
    final paint = Paint()
      ..blendMode = BlendMode.srcOver
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    for (var i = 0; i < lobeOffsets.length; i += 1) {
      final scale = 0.56 + (i % 3) * 0.16;
      final radius = cluster.baseRadius * scale;
      final lobeCenter = Offset(
        center.dx + lobeOffsets[i].dx * cluster.baseRadius,
        center.dy + lobeOffsets[i].dy * cluster.baseRadius,
      );
      paint.color = cluster.color.withValues(alpha: 0.72 + (i * 0.05));
      canvas.drawCircle(lobeCenter, radius, paint);
    }

    // Ragged/frayed edge detail with irregular micro-lobes.
    const edgeCount = 20;
    for (var i = 0; i < edgeCount; i += 1) {
      final angle = (i / edgeCount) * math.pi * 2 + cluster.phase * 0.35;
      final outward = cluster.baseRadius * (0.9 + 0.45 * math.sin(i * 1.7));
      final jitter = cluster.baseRadius * (0.12 * math.cos(i * 2.3));
      final edgeCenter = Offset(
        center.dx + math.cos(angle) * (outward + jitter),
        center.dy + math.sin(angle) * (outward + jitter),
      );
      final edgeRadius =
          cluster.baseRadius * (0.11 + (0.08 * math.sin(i * 2.1).abs()));
      paint.color = cluster.color.withValues(
        alpha: (0.42 + 0.2 * math.sin(i * 1.1 + cluster.phase).abs()),
      );
      canvas.drawCircle(edgeCenter, edgeRadius, paint);
    }
  }

  double _wrap(double value, double period) {
    if (period <= 0) return 0;
    final mod = value % period;
    return mod < 0 ? mod + period : mod;
  }

  @override
  bool shouldRepaint(covariant _VictoryCottonPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.clusters != clusters;
  }
}
