import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/audio/sound_effect.dart';
import '../../core/configuration/kiosk_configuration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum GpaButtonState { normal, pressed, loading, disabled, success }

class GpaPrimaryButton extends StatelessWidget {
  const GpaPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.state = GpaButtonState.normal,
    this.expand = false,
    this.sound = SoundEffect.tap,
    this.unlockSound = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GpaButtonState state;
  final bool expand;
  final SoundEffect sound;
  final bool unlockSound;

  @override
  Widget build(BuildContext context) {
    return _GpaButtonSurface(
      label: label,
      icon: icon,
      onPressed: onPressed,
      state: state,
      variant: _GpaButtonVariant.primary,
      expand: expand,
      sound: sound,
      unlockSound: unlockSound,
    );
  }
}

class GpaSecondaryButton extends StatelessWidget {
  const GpaSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.state = GpaButtonState.normal,
    this.expand = false,
    this.sound = SoundEffect.tap,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GpaButtonState state;
  final bool expand;
  final SoundEffect sound;

  @override
  Widget build(BuildContext context) {
    return _GpaButtonSurface(
      label: label,
      icon: icon,
      onPressed: onPressed,
      state: state,
      variant: _GpaButtonVariant.secondary,
      expand: expand,
      sound: sound,
    );
  }
}

class GpaIconButton extends StatelessWidget {
  const GpaIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.state = GpaButtonState.normal,
    this.sound = SoundEffect.tap,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final GpaButtonState state;
  final SoundEffect sound;

  @override
  Widget build(BuildContext context) {
    return _GpaButtonSurface(
      label: semanticLabel,
      icon: icon,
      onPressed: onPressed,
      state: state,
      variant: _GpaButtonVariant.icon,
      sound: sound,
      semanticLabel: semanticLabel,
    );
  }
}

enum _GpaButtonVariant { primary, secondary, icon }

class _GpaButtonSurface extends StatefulWidget {
  const _GpaButtonSurface({
    required this.label,
    required this.onPressed,
    required this.state,
    required this.variant,
    required this.sound,
    this.icon,
    this.expand = false,
    this.unlockSound = false,
    this.semanticLabel,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GpaButtonState state;
  final _GpaButtonVariant variant;
  final bool expand;
  final SoundEffect sound;
  final bool unlockSound;
  final String? semanticLabel;

  @override
  State<_GpaButtonSurface> createState() => _GpaButtonSurfaceState();
}

class _GpaButtonSurfaceState extends State<_GpaButtonSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleController;
  Offset _rippleOrigin = Offset.zero;
  bool _pressed = false;

  bool get _enabled {
    return widget.onPressed != null &&
        widget.state != GpaButtonState.disabled &&
        widget.state != GpaButtonState.loading;
  }

  bool get _visuallyPressed {
    return _pressed || widget.state == GpaButtonState.pressed;
  }

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: AppMotion.ripple,
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_enabled) return;
    setState(() {
      _pressed = true;
      _rippleOrigin = details.localPosition;
    });
    _rippleController.forward(from: 0);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_enabled) return;
    setState(() => _pressed = false);
    _activate();
  }

  void _handleTapCancel() {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  void _activate() {
    final controller = SoundControllerScope.maybeOf(context);
    if (controller != null) {
      if (widget.unlockSound) {
        unawaited(controller.unlock(firstSound: widget.sound));
      } else {
        unawaited(controller.play(widget.sound));
      }
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = _GpaButtonStyle.resolve(
      widget.variant,
      widget.state,
      _enabled,
    );
    final duration = _visuallyPressed ? AppMotion.touchDown : AppMotion.touchUp;
    final height = widget.variant == _GpaButtonVariant.icon
        ? KioskConfiguration.iconControlSize
        : KioskConfiguration.primaryControlHeight;
    final width = widget.variant == _GpaButtonVariant.icon ? height : null;
    final radius = BorderRadius.circular(
      widget.variant == _GpaButtonVariant.icon ? 18 : 18,
    );

    Widget content = _ButtonContent(
      label: widget.label,
      icon: widget.icon,
      state: widget.state,
      variant: widget.variant,
      foregroundColor: style.foreground,
    );
    content = Padding(
      padding: widget.variant == _GpaButtonVariant.icon
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 28),
      child: content,
    );

    final button = Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? _handleTapDown : null,
        onTapUp: _enabled ? _handleTapUp : null,
        onTapCancel: _enabled ? _handleTapCancel : null,
        child: AnimatedSlide(
          duration: duration,
          curve: AppMotion.standardCurve,
          offset: Offset(0, _visuallyPressed ? 2 / height : 0),
          child: AnimatedScale(
            duration: duration,
            curve: AppMotion.standardCurve,
            scale: _visuallyPressed ? 0.975 : 1,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.standardCurve,
              width: width,
              height: height,
              constraints: const BoxConstraints(
                minWidth: KioskConfiguration.minimumTouchTarget,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: radius,
                border: Border.all(color: style.border, width: 1.25),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _GpaRipplePainter(
                          origin: _rippleOrigin,
                          progress: Curves.easeOut.transform(
                            _rippleController.value,
                          ),
                          color: style.ripple,
                        ),
                      );
                    },
                  ),
                  Center(child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.state,
    required this.variant,
    required this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final GpaButtonState state;
  final _GpaButtonVariant variant;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (state == GpaButtonState.loading) {
      return SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: foregroundColor,
        ),
      );
    }

    final resolvedIcon = state == GpaButtonState.success
        ? Icons.check_rounded
        : icon;
    if (variant == _GpaButtonVariant.icon) {
      return Icon(resolvedIcon, color: foregroundColor, size: 28);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (resolvedIcon != null) ...[
          Icon(resolvedIcon, color: foregroundColor, size: 24),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.button.copyWith(color: foregroundColor),
          ),
        ),
      ],
    );
  }
}

class _GpaButtonStyle {
  const _GpaButtonStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.ripple,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color ripple;

  static _GpaButtonStyle resolve(
    _GpaButtonVariant variant,
    GpaButtonState state,
    bool enabled,
  ) {
    if (!enabled || state == GpaButtonState.disabled) {
      return _GpaButtonStyle(
        background: variant == _GpaButtonVariant.primary
            ? AppColors.steel.withValues(alpha: 0.65)
            : AppColors.steel.withValues(alpha: 0.10),
        foreground: variant == _GpaButtonVariant.primary
            ? AppColors.pureWhite
            : AppColors.steel,
        border: AppColors.steel.withValues(alpha: 0.28),
        ripple: Colors.transparent,
      );
    }

    if (state == GpaButtonState.success) {
      return _GpaButtonStyle(
        background: variant == _GpaButtonVariant.primary
            ? AppColors.successGreen
            : AppColors.pureWhite,
        foreground: variant == _GpaButtonVariant.primary
            ? AppColors.pureWhite
            : AppColors.successGreen,
        border: AppColors.successGreen,
        ripple: AppColors.pureWhite.withValues(alpha: 0.10),
      );
    }

    return switch (variant) {
      _GpaButtonVariant.primary => _GpaButtonStyle(
        background: AppColors.gpaCrimson,
        foreground: AppColors.pureWhite,
        border: AppColors.gpaCrimson,
        ripple: AppColors.pureWhite.withValues(alpha: 0.11),
      ),
      _GpaButtonVariant.secondary => _GpaButtonStyle(
        background: AppColors.pureWhite,
        foreground: AppColors.gpaCrimson,
        border: AppColors.gpaCrimson.withValues(alpha: 0.72),
        ripple: AppColors.gpaCrimson.withValues(alpha: 0.07),
      ),
      _GpaButtonVariant.icon => _GpaButtonStyle(
        background: AppColors.pureWhite,
        foreground: AppColors.carbon,
        border: AppColors.steel.withValues(alpha: 0.28),
        ripple: AppColors.gpaCrimson.withValues(alpha: 0.07),
      ),
    };
  }
}

class _GpaRipplePainter extends CustomPainter {
  const _GpaRipplePainter({
    required this.origin,
    required this.progress,
    required this.color,
  });

  final Offset origin;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || color.a == 0) return;

    final farthestX = math.max(origin.dx, size.width - origin.dx);
    final farthestY = math.max(origin.dy, size.height - origin.dy);
    final maxRadius = math.sqrt(
      (farthestX * farthestX) + (farthestY * farthestY),
    );
    final paint = Paint()
      ..color = color.withValues(alpha: color.a * (1 - progress));
    canvas.drawCircle(origin, maxRadius * progress, paint);
  }

  @override
  bool shouldRepaint(covariant _GpaRipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.origin != origin ||
        oldDelegate.color != color;
  }
}
