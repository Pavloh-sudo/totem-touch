import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/area_colors.dart';

enum GpMascotState { idle, wave, thinking, guide, celebrate, error }

enum GpMascotContext {
  defaultOutfit,
  robotics,
  cutting,
  manufacturing,
  machinery,
  software,
  careers,
}

class GpMascot extends StatelessWidget {
  const GpMascot({
    required this.artwork,
    this.state = GpMascotState.idle,
    this.mascotContext = GpMascotContext.defaultOutfit,
    this.size = 240,
    super.key,
  });

  final Widget artwork;
  final GpMascotState state;
  final GpMascotContext mascotContext;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: state.semanticsLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: mascotContext.accentColor.withValues(alpha: 0.08),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          offset: state.slideOffset,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            turns: state.rotationTurns,
            child: AnimatedScale(
              key: ValueKey('${state.name}-${mascotContext.name}'),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              scale: state.scale,
              child: artwork,
            ),
          ),
        ),
      ),
    );
  }
}

extension on GpMascotState {
  String get semanticsLabel {
    return switch (this) {
      GpMascotState.idle => 'GP listo para ayudarte',
      GpMascotState.wave => 'GP saludando',
      GpMascotState.thinking => 'GP pensando',
      GpMascotState.guide => 'GP mostrando el camino',
      GpMascotState.celebrate => 'GP celebrando',
      GpMascotState.error => 'GP indicando que algo salió mal',
    };
  }

  double get scale {
    return switch (this) {
      GpMascotState.thinking => 0.97,
      GpMascotState.celebrate => 1.06,
      _ => 1,
    };
  }

  double get rotationTurns {
    return switch (this) {
      GpMascotState.wave => -0.018,
      GpMascotState.error => 0.012,
      _ => 0,
    };
  }

  Offset get slideOffset {
    return switch (this) {
      GpMascotState.guide => const Offset(0.035, 0),
      GpMascotState.celebrate => const Offset(0, -0.035),
      _ => Offset.zero,
    };
  }
}

extension on GpMascotContext {
  Color get accentColor {
    return switch (this) {
      GpMascotContext.defaultOutfit => AppColors.gpaCrimson,
      GpMascotContext.robotics => AreaColors.robotics,
      GpMascotContext.cutting => AreaColors.cutting,
      GpMascotContext.manufacturing => AreaColors.manufacturing,
      GpMascotContext.machinery => AreaColors.machinery,
      GpMascotContext.software => AreaColors.software,
      GpMascotContext.careers => AreaColors.careers,
    };
  }
}
