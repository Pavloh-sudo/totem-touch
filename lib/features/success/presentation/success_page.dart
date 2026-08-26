import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/registration_session.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/mascot/gp_mascot.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({
    required this.submission,
    required this.onFinish,
    super.key,
  });

  final RegistrationSession submission;
  final VoidCallback onFinish;

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  late final AnimationController _checkController;
  late final AnimationController _confettiController;
  late final Animation<double> _circleScale;

  Timer? _checkTimer;
  Timer? _soundTimer;
  Timer? _countdownRevealTimer;
  Timer? _countdownTimer;
  Timer? _finishTimer;
  bool _showCountdown = false;
  bool _finished = false;
  int _remainingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: AppMotion.successCircle,
    );
    _checkController = AnimationController(
      vsync: this,
      duration: AppMotion.successCheck,
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: AppMotion.successConfetti,
    );
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.12,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 32,
      ),
    ]).animate(_circleController);

    _circleController.forward();
    _confettiController.forward();
    _checkTimer = Timer(const Duration(milliseconds: 70), () {
      if (mounted) _checkController.forward();
    });
    _soundTimer = Timer(AppMotion.successSoundDelay, _playSuccessSound);
    _countdownRevealTimer = Timer(
      AppMotion.successCountdownDelay,
      _showResetCountdown,
    );
    _finishTimer = Timer(AppMotion.successVisible, _finish);
  }

  void _playSuccessSound() {
    if (!mounted) return;
    final controller = SoundControllerScope.maybeOf(context);
    if (controller != null) unawaited(controller.play(SoundEffect.success));
  }

  void _showResetCountdown() {
    if (!mounted || _finished) return;
    setState(() => _showCountdown = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || _remainingSeconds <= 1) return;
      setState(() => _remainingSeconds--);
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _cancelTimers();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.submission;
    final informationCopy = session.wantsInformation
        ? 'Registramos tus intereses y podremos compartir contigo información '
              'relacionada con las áreas que elegiste.'
        : 'Tu registro quedó completo. Gracias por contarnos qué te interesa '
              'de Grupo GPA.';

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  key: const ValueKey('success-confetti'),
                  painter: _ConfettiPainter(
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      key: const ValueKey('success-circle'),
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.11),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.successGreen,
                          width: 2,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _checkController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _AnimatedCheckPainter(
                              progress: Curves.easeOutCubic.transform(
                                _checkController.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Gracias por conectar con GPA',
                    style: AppTypography.hero.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lo que te interesa también nos interesa.',
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 570),
                    child: Text(
                      informationCopy,
                      style: AppTypography.body.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 570),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: AppSurfaces.card(selected: true),
                    child: Text(
                      session.interestPath.join('  ›  '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color: AppColors.gpaCrimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: GpaSecondaryButton(
                          label: 'Finalizar',
                          icon: Icons.arrow_forward_rounded,
                          trailingIcon: true,
                          sound: SoundEffect.tap,
                          onPressed: _finished ? null : _finish,
                        ),
                      ),
                      const SizedBox(width: 20),
                      AnimatedOpacity(
                        duration: AppMotion.standard,
                        opacity: _showCountdown ? 1 : 0,
                        child: Text(
                          'Nueva sesión en $_remainingSeconds s',
                          key: const ValueKey('success-reset-countdown'),
                          style: AppTypography.auxiliary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: GpMascot(
                  key: const ValueKey('success-mascot'),
                  size: 310,
                  state: GpMascotState.celebrate,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _cancelTimers() {
    _checkTimer?.cancel();
    _soundTimer?.cancel();
    _countdownRevealTimer?.cancel();
    _countdownTimer?.cancel();
    _finishTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _circleController.dispose();
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

class _AnimatedCheckPainter extends CustomPainter {
  const _AnimatedCheckPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.27, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.35);
    final metric = path.computeMetrics().first;
    final visiblePath = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      visiblePath,
      Paint()
        ..color = AppColors.successGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  static const _particleCount = 22;
  static const _colors = [
    AppColors.gpaCrimson,
    AppColors.graphite,
    AppColors.techCyan,
    AppColors.pureWhite,
  ];

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final origin = Offset(size.width * 0.77, size.height * 0.43);
    final fade = (1 - Curves.easeIn.transform(progress)).clamp(0.0, 1.0);

    for (var index = 0; index < _particleCount; index++) {
      final angle =
          (-math.pi * 0.92) + ((index / (_particleCount - 1)) * math.pi * 1.84);
      final distance = 115 + ((index * 37) % 105);
      final horizontal = math.cos(angle) * distance * progress;
      final vertical =
          (math.sin(angle) * distance * progress) + (180 * progress * progress);
      final center = origin + Offset(horizontal, vertical);
      final color = _colors[index % _colors.length].withValues(alpha: fade);
      final paint = Paint()..color = color;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((index * 0.7) + (progress * math.pi * 2));
      if (index.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 7 + (index % 4),
              height: 16,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, 5 + (index % 3), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
