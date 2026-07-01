import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryConfettiOverlay extends StatefulWidget {
  const VictoryConfettiOverlay({super.key});

  @override
  State<VictoryConfettiOverlay> createState() => _VictoryConfettiOverlayState();
}

class _VictoryConfettiOverlayState extends State<VictoryConfettiOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _sequenceDuration = Duration(seconds: 8);
  static const double _sequenceSeconds = 8.0;
  static const int _pieceCount = 96;
  static const List<Color> _colors = <Color>[
    Color(0xFFFFC857),
    Color(0xFFFF6B6B),
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFE26DFF),
    Color(0xFFFF9F45),
  ];
  final math.Random _random = math.Random(20260514);
  late final AnimationController _controller;
  late final List<_ConfettiSpec> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _sequenceDuration)
      ..forward();
    _pieces = List<_ConfettiSpec>.generate(_pieceCount, (_) {
      return _ConfettiSpec(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 6 + _random.nextDouble() * 8,
        color: _colors[_random.nextInt(_colors.length)],
        fallSpeed: 90 + _random.nextDouble() * 150,
        driftAmplitude: 12 + _random.nextDouble() * 30,
        driftFrequencyA: 1.2 + _random.nextDouble() * 2.4,
        driftFrequencyB: 0.8 + _random.nextDouble() * 2.0,
        driftPhaseA: _random.nextDouble() * math.pi * 2,
        driftPhaseB: _random.nextDouble() * math.pi * 2,
        rotateXSpeed: -2.2 + _random.nextDouble() * 4.4,
        rotateYSpeed: -2.5 + _random.nextDouble() * 5.0,
        rotateZSpeed: -2.8 + _random.nextDouble() * 5.6,
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
          key: const ValueKey<String>('victory-confetti-overlay'),
          painter: _VictoryConfettiPainter(
            progress: _controller.value,
            pieces: _pieces,
          ),
        );
      },
    );
  }
}

class _ConfettiSpec {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double fallSpeed;
  final double driftAmplitude;
  final double driftFrequencyA;
  final double driftFrequencyB;
  final double driftPhaseA;
  final double driftPhaseB;
  final double rotateXSpeed;
  final double rotateYSpeed;
  final double rotateZSpeed;
  final double rotatePhase;

  const _ConfettiSpec({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.fallSpeed,
    required this.driftAmplitude,
    required this.driftFrequencyA,
    required this.driftFrequencyB,
    required this.driftPhaseA,
    required this.driftPhaseB,
    required this.rotateXSpeed,
    required this.rotateYSpeed,
    required this.rotateZSpeed,
    required this.rotatePhase,
  });
}

class _VictoryConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiSpec> pieces;

  const _VictoryConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress * _VictoryConfettiOverlayState._sequenceSeconds;
    for (final piece in pieces) {
      final startX = size.width * piece.x;
      final startY = size.height * piece.y;
      final y =
          _wrap(
            startY + (piece.fallSpeed * seconds),
            size.height + piece.size,
          ) -
          piece.size;
      final x =
          startX +
          piece.driftAmplitude *
              (math.sin(seconds * piece.driftFrequencyA + piece.driftPhaseA) +
                  0.6 *
                      math.sin(
                        seconds * piece.driftFrequencyB + piece.driftPhaseB,
                      ));

      final rx = piece.rotatePhase + (seconds * piece.rotateXSpeed);
      final ry = piece.rotatePhase * 0.8 + (seconds * piece.rotateYSpeed);
      final rz = piece.rotatePhase * 1.2 + (seconds * piece.rotateZSpeed);
      final scaleX = 0.3 + (math.cos(ry).abs() * 0.9);
      final scaleY = 0.35 + (math.cos(rx).abs() * 0.9);
      final alpha = (0.45 + 0.55 * math.sin(rz).abs())
          .clamp(0.0, 1.0)
          .toDouble();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rz);
      canvas.transform(
        (Matrix4.identity()
              ..setEntry(3, 2, 0.0025)
              ..rotateX(rx)
              ..rotateY(ry))
            .storage,
      );
      canvas.scale(scaleX, scaleY);
      final r = piece.size / 2;
      final paint = Paint()..color = piece.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset.zero, r, paint);
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withValues(alpha: alpha * 0.45),
      );
      canvas.restore();
    }
  }

  double _wrap(double value, double period) {
    if (period <= 0) return 0;
    final mod = value % period;
    return mod < 0 ? mod + period : mod;
  }

  @override
  bool shouldRepaint(covariant _VictoryConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pieces != pieces;
  }
}
