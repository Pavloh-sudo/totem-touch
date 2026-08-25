import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TechnicalBackground extends StatelessWidget {
  const TechnicalBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.porcelain,
      child: RepaintBoundary(
        child: CustomPaint(
          key: const ValueKey('technical-background'),
          painter: const _TechnicalPatternPainter(),
          child: child,
        ),
      ),
    );
  }
}

class _TechnicalPatternPainter extends CustomPainter {
  const _TechnicalPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawCircuit(canvas, size);
    _drawGearMotif(canvas, Offset(size.width * 0.9, size.height * 0.12), 92);
    _drawGearMotif(canvas, Offset(size.width * 0.08, size.height * 0.92), 58);
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
  bool shouldRepaint(covariant _TechnicalPatternPainter oldDelegate) => false;
}
