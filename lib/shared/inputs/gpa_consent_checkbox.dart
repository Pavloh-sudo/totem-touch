import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/audio/sound_effect.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class GpaConsentCheckbox extends StatefulWidget {
  const GpaConsentCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<GpaConsentCheckbox> createState() => _GpaConsentCheckboxState();
}

class _GpaConsentCheckboxState extends State<GpaConsentCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: AppMotion.checkboxCheck,
      value: widget.value ? 1 : 0,
    );
    _checkScale = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.12), weight: 62),
        TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 38),
      ],
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant GpaConsentCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    if (widget.value) {
      _checkController.forward(from: 0);
    } else {
      _checkController.reverse();
    }
  }

  void _toggle() {
    final soundController = SoundControllerScope.maybeOf(context);
    if (soundController != null) {
      unawaited(
        soundController.play(SoundEffect.selection, volumeScale: 2 / 3),
      );
    }
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: widget.value,
      label: 'Acepto compartir mis datos con Grupo GPA. Campo requerido',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: AppMotion.checkboxContainer,
          curve: AppMotion.standardCurve,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.value
                ? AppColors.gpaCrimson.withValues(alpha: 0.055)
                : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.value
                  ? AppColors.gpaCrimson
                  : AppColors.steel.withValues(alpha: 0.55),
              width: widget.value ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.checkboxContainer,
                curve: AppMotion.standardCurve,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.value
                      ? AppColors.gpaCrimson
                      : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.value
                        ? AppColors.gpaCrimson
                        : AppColors.steel,
                    width: 1.6,
                  ),
                ),
                child: FadeTransition(
                  opacity: _checkController,
                  child: ScaleTransition(
                    scale: _checkScale,
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.pureWhite,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Acepto compartir mis datos con Grupo GPA y recibir '
                        'información relacionada con los temas que seleccione.',
                        style: AppTypography.label.copyWith(
                          color: AppColors.carbon,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gpaCrimson.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Requerido',
                        style: AppTypography.auxiliary.copyWith(
                          color: AppColors.gpaCrimson,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }
}
