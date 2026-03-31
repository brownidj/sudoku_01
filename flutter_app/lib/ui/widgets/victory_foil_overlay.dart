import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoryFoilOverlay extends StatefulWidget {
  final int pieceCount;

  const VictoryFoilOverlay({super.key, this.pieceCount = 220});

  @override
  State<VictoryFoilOverlay> createState() => _VictoryFoilOverlayState();
}

class _VictoryFoilOverlayState extends State<VictoryFoilOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _loopDuration = Duration(seconds: 12);
  late final AnimationController _controller;
  late final List<_FoilPieceSpec> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random(20260331);
    _pieces = List<_FoilPieceSpec>.generate(
      widget.pieceCount,
      (_) => _FoilPieceSpec.random(random),
      growable: false,
    );
    _controller = AnimationController(vsync: this, duration: _loopDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _VictoryFoilPainter(
                  progress: _controller.value,
                  pieces: _pieces,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VictoryFoilPainter extends CustomPainter {
  final double progress;
  final List<_FoilPieceSpec> pieces;

  const _VictoryFoilPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress * 12.0;
    final overlayPaint = Paint()
      ..color = const Color.fromRGBO(211, 211, 211, 0.25);
    canvas.drawRect(Offset.zero & size, overlayPaint);
    for (final piece in pieces) {
      final cycleHeight = size.height + piece.height;
      final y =
          _wrap(piece.startY + piece.fallSpeed * seconds, cycleHeight) -
          piece.height;
      final x =
          _wrap(
            piece.startX +
                piece.flutterAmplitude *
                    math.sin(
                      piece.flutterFrequency * seconds + piece.flutterPhase,
                    ),
            size.width + piece.width,
          ) -
          piece.width * 0.5;
      final angle = piece.rotationOffset + piece.rotationSpeed * seconds;
      _paintFoilPiece(
        canvas: canvas,
        x: x,
        y: y,
        width: piece.width,
        height: piece.height,
        angle: angle,
      );
    }
  }

  void _paintFoilPiece({
    required Canvas canvas,
    required double x,
    required double y,
    required double width,
    required double height,
    required double angle,
  }) {
    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(angle);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFD700), Color(0xFFC89600)],
      ).createShader(rect);
    canvas.drawRect(rect, fill);
    final stroke = Paint()
      ..color = const Color(0xFFC89600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, stroke);
    canvas.restore();
  }

  double _wrap(double value, double period) {
    if (period <= 0) {
      return 0;
    }
    final mod = value % period;
    return mod < 0 ? mod + period : mod;
  }

  @override
  bool shouldRepaint(covariant _VictoryFoilPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pieces != pieces;
  }
}

class _FoilPieceSpec {
  final double width;
  final double height;
  final double startX;
  final double startY;
  final double fallSpeed;
  final double flutterAmplitude;
  final double flutterFrequency;
  final double flutterPhase;
  final double rotationOffset;
  final double rotationSpeed;

  const _FoilPieceSpec({
    required this.width,
    required this.height,
    required this.startX,
    required this.startY,
    required this.fallSpeed,
    required this.flutterAmplitude,
    required this.flutterFrequency,
    required this.flutterPhase,
    required this.rotationOffset,
    required this.rotationSpeed,
  });

  factory _FoilPieceSpec.random(math.Random random) {
    return _FoilPieceSpec(
      width: 6 + random.nextDouble() * 12,
      height: 4 + random.nextDouble() * 6,
      startX: random.nextDouble() * 2000,
      startY: -12 + random.nextDouble() * 350,
      fallSpeed: 70 + random.nextDouble() * 90,
      flutterAmplitude: 1 + random.nextDouble() * 4,
      flutterFrequency: 2 + random.nextDouble() * 3,
      flutterPhase: random.nextDouble() * math.pi * 2,
      rotationOffset: random.nextDouble() * math.pi * 2,
      rotationSpeed: -0.7 + random.nextDouble() * 1.4,
    );
  }
}
