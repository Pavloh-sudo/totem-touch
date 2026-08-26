part of '../gp_mascot.dart';

class _GpContextAccessoryPainter extends CustomPainter {
  const _GpContextAccessoryPainter(this.mascotContext);

  final GpMascotContext mascotContext;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1024, size.height / 1024);

    switch (mascotContext) {
      case GpMascotContext.robotics:
        _paintRobotics(canvas);
      case GpMascotContext.cutting:
        _paintCuttingVisor(canvas);
      case GpMascotContext.manufacturing:
        _paintTool(canvas);
      case GpMascotContext.machinery:
        _paintBlueprint(canvas);
      case GpMascotContext.software:
        _paintTablet(canvas);
      case GpMascotContext.careers:
        _paintBadge(canvas);
      case GpMascotContext.defaultOutfit:
        break;
    }
    canvas.restore();
  }

  void _paintRobotics(Canvas canvas) {
    final accent = AreaColors.robotics;
    final line = Paint()
      ..color = AppColors.carbon
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(670, 119), const Offset(705, 56), line);
    canvas.drawCircle(const Offset(708, 50), 23, Paint()..color = accent);
    canvas.drawCircle(
      const Offset(708, 50),
      9,
      Paint()..color = AppColors.pureWhite,
    );

    final circuit = Paint()
      ..color = accent.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(382, 220)
      ..lineTo(420, 190)
      ..lineTo(458, 190);
    canvas.drawPath(path, circuit);
    canvas.drawCircle(const Offset(472, 190), 10, Paint()..color = accent);
  }

  void _paintCuttingVisor(Canvas canvas) {
    final visor = RRect.fromRectAndRadius(
      const Rect.fromLTWH(337, 302, 350, 142),
      const Radius.circular(54),
    );
    canvas.drawRRect(
      visor,
      Paint()..color = AreaColors.cutting.withValues(alpha: 0.24),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..color = AreaColors.cutting.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );
    canvas.drawLine(
      const Offset(347, 328),
      const Offset(677, 328),
      Paint()
        ..color = AppColors.pureWhite.withValues(alpha: 0.46)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintTool(Canvas canvas) {
    canvas.save();
    canvas.translate(688, 595);
    canvas.rotate(-0.52);
    final outline = Paint()
      ..color = AppColors.carbon
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 34;
    final metal = Paint()
      ..color = AreaColors.manufacturing
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 22;
    canvas.drawLine(const Offset(0, 20), const Offset(0, 210), outline);
    canvas.drawLine(const Offset(0, 20), const Offset(0, 210), metal);
    canvas.drawCircle(const Offset(0, 210), 26, outline);
    canvas.drawCircle(
      const Offset(0, 210),
      12,
      Paint()..color = AppColors.pureWhite,
    );
    final jaw = Path()
      ..moveTo(-38, -12)
      ..quadraticBezierTo(0, 30, 38, -12)
      ..lineTo(23, -48)
      ..quadraticBezierTo(0, -23, -23, -48)
      ..close();
    canvas.drawPath(jaw, outline);
    canvas.drawPath(
      jaw,
      Paint()
        ..color = AreaColors.manufacturing
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  void _paintBlueprint(Canvas canvas) {
    final sheet = RRect.fromRectAndRadius(
      const Rect.fromLTWH(365, 578, 294, 192),
      const Radius.circular(20),
    );
    canvas.drawRRect(sheet, Paint()..color = AppColors.carbon);
    canvas.drawRRect(sheet.deflate(9), Paint()..color = AreaColors.machinery);
    final detail = Paint()
      ..color = AppColors.pureWhite.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawRect(const Rect.fromLTWH(405, 617, 84, 72), detail);
    canvas.drawCircle(const Offset(560, 660), 38, detail);
    canvas.drawLine(const Offset(405, 720), const Offset(612, 720), detail);
  }

  void _paintTablet(Canvas canvas) {
    final device = RRect.fromRectAndRadius(
      const Rect.fromLTWH(388, 558, 248, 220),
      const Radius.circular(30),
    );
    canvas.drawRRect(device, Paint()..color = AppColors.carbon);
    final screen = RRect.fromRectAndRadius(
      const Rect.fromLTWH(407, 578, 210, 164),
      const Radius.circular(17),
    );
    canvas.drawRRect(screen, Paint()..color = AreaColors.software);
    final code = Paint()
      ..color = AppColors.pureWhite.withValues(alpha: 0.86)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(440, 623), const Offset(505, 623), code);
    canvas.drawLine(const Offset(458, 655), const Offset(574, 655), code);
    canvas.drawLine(const Offset(440, 687), const Offset(536, 687), code);
    canvas.drawCircle(
      const Offset(512, 758),
      7,
      Paint()..color = AppColors.pureWhite,
    );
  }

  void _paintBadge(Canvas canvas) {
    final lanyard = Paint()
      ..color = AreaColors.careers
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(428, 520)
      ..lineTo(500, 650)
      ..lineTo(596, 520);
    canvas.drawPath(path, lanyard);
    final badge = RRect.fromRectAndRadius(
      const Rect.fromLTWH(435, 625, 154, 132),
      const Radius.circular(18),
    );
    canvas.drawRRect(badge, Paint()..color = AppColors.pureWhite);
    canvas.drawRRect(
      badge,
      Paint()
        ..color = AreaColors.careers
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );
    canvas.drawCircle(
      const Offset(477, 674),
      20,
      Paint()..color = AreaColors.careers.withValues(alpha: 0.74),
    );
    canvas.drawLine(
      const Offset(515, 666),
      const Offset(558, 666),
      Paint()
        ..color = AppColors.graphite
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(466, 714),
      const Offset(558, 714),
      Paint()
        ..color = AppColors.steel
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GpContextAccessoryPainter oldDelegate) {
    return oldDelegate.mascotContext != mascotContext;
  }
}
