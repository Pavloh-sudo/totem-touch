import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TechnicalBackground extends StatefulWidget {
  const TechnicalBackground({required this.child, super.key});

  final Widget child;

  @override
  State<TechnicalBackground> createState() => _TechnicalBackgroundState();
}

class _TechnicalBackgroundState extends State<TechnicalBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final tickersEnabled = TickerMode.valuesOf(context).enabled;
    if (reduceMotion || !tickersEnabled) {
      _ambientController
        ..stop()
        ..value = 0;
    } else if (!_ambientController.isAnimating) {
      _ambientController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.porcelain,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ambientController,
          builder: (context, child) {
            return CustomPaint(
              key: const ValueKey('technical-background'),
              painter: _TechnicalPatternPainter(_ambientController.value),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }
}

class _TechnicalPatternPainter extends CustomPainter {
  const _TechnicalPatternPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    final cycle = progress * math.pi * 2;
    final circuitOffset = Offset(math.sin(cycle) * 6, math.cos(cycle) * 4);
    final gearOffset = Offset(math.cos(cycle) * 8, math.sin(cycle) * 6);
    canvas.save();
    canvas.translate(circuitOffset.dx, circuitOffset.dy);
    _drawCircuit(canvas, size);
    canvas.restore();
    _drawGearMotif(
      canvas,
      Offset(size.width * 0.9, size.height * 0.12) + gearOffset,
      92,
    );
    _drawGearMotif(
      canvas,
      Offset(size.width * 0.08, size.height * 0.92) - (gearOffset * 0.65),
      58,
    );
    _drawAmbientWave(canvas, size, cycle);
  }

  void _drawAmbientWave(Canvas canvas, Size size, double cycle) {
    final paint = Paint()
      ..color = AppColors.techCyan.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(
      size.width * 0.62 + (math.sin(cycle) * 5),
      size.height * 0.43 + (math.cos(cycle) * 4),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 78),
      -0.8,
      2.2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 104),
      2.1,
      1.7,
      false,
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.steel.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    final dotPaint = Paint()
      ..color = AppColors.techCyan.withValues(alpha: 0.045);

    for (double x = 32; x < size.width; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 32; y < size.height; y += 64) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 32; x < size.width; x += 128) {
      for (double y = 32; y < size.height; y += 128) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  void _drawCircuit(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.carbon.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.16)
      ..lineTo(size.width * 0.31, size.height * 0.16)
      ..lineTo(size.width * 0.35, size.height * 0.22)
      ..lineTo(size.width * 0.48, size.height * 0.22)
      ..moveTo(size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width * 0.62, size.height * 0.75)
      ..lineTo(size.width * 0.58, size.height * 0.69)
      ..lineTo(size.width * 0.48, size.height * 0.69);
    canvas.drawPath(path, paint);
  }

  void _drawGearMotif(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.gpaCrimson.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.68, paint);

    for (var index = 0; index < 12; index++) {
      final angle = (math.pi * 2 / 12) * index;
      final inner = Offset(
        center.dx + math.cos(angle) * radius * 1.02,
        center.dy + math.sin(angle) * radius * 1.02,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * radius * 1.14,
        center.dy + math.sin(angle) * radius * 1.14,
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TechnicalPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
