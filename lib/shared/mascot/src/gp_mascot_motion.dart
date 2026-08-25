part of '../gp_mascot.dart';

class _GpMascotCapabilities {
  const _GpMascotCapabilities({
    required this.supportsBlink,
    required this.supportsHeadMotion,
    required this.supportsShadow,
    required this.supportsArticulation,
  });

  const _GpMascotCapabilities.flat()
    : supportsBlink = false,
      supportsHeadMotion = false,
      supportsShadow = false,
      supportsArticulation = false;

  final bool supportsBlink;
  final bool supportsHeadMotion;
  final bool supportsShadow;
  final bool supportsArticulation;

  factory _GpMascotCapabilities.fromArtwork(Widget artwork) {
    if (artwork case _GpArtworkLayers layers) {
      return _GpMascotCapabilities(
        supportsBlink: layers.closedEyes != null,
        supportsHeadMotion: layers.head != null,
        supportsShadow: layers.shadow != null,
        supportsArticulation: layers.hasArticulatedPoses,
      );
    }
    return const _GpMascotCapabilities.flat();
  }
}

class _GpMascotPose {
  const _GpMascotPose({
    this.scale = 1,
    this.translateX = 0,
    this.translateY = 0,
    this.rotationDegrees = 0,
  });

  final double scale;
  final double translateX;
  final double translateY;
  final double rotationDegrees;
}

_GpMascotPose _poseForState(
  GpMascotState state,
  double progress,
  double pixelScale,
  bool reduceMotion,
  bool articulated,
) {
  if (articulated) {
    if (reduceMotion) return const _GpMascotPose();

    return switch (state) {
      GpMascotState.wave => _GpMascotPose(
        translateY: -1.5 * pixelScale * math.sin(math.pi * progress),
      ),
      GpMascotState.celebrate => _GpMascotPose(
        scale: 1 + (math.sin(math.pi * progress) * 0.025),
        translateY: -7 * pixelScale * math.sin(math.pi * progress),
      ),
      GpMascotState.error => _GpMascotPose(
        translateX:
            math.sin(progress * math.pi * 3) * 3 * pixelScale * (1 - progress),
      ),
      _ => const _GpMascotPose(),
    };
  }

  if (reduceMotion) {
    return switch (state) {
      GpMascotState.thinking => const _GpMascotPose(
        scale: 0.995,
        rotationDegrees: -0.7,
      ),
      GpMascotState.guide => _GpMascotPose(translateX: 1.5 * pixelScale),
      _ => const _GpMascotPose(),
    };
  }

  final eased = Curves.easeOutCubic.transform(progress);
  return switch (state) {
    GpMascotState.idle => const _GpMascotPose(),
    GpMascotState.wave => _GpMascotPose(
      scale: 1 + (math.sin(math.pi * progress) * 0.004),
      translateY: -1.5 * pixelScale * math.sin(math.pi * progress),
      rotationDegrees:
          math.sin(progress * math.pi * 5) * 0.8 * (1 - progress * 0.3),
    ),
    GpMascotState.thinking => _GpMascotPose(
      scale: 1 - (0.005 * eased),
      rotationDegrees: -1.4 * eased,
    ),
    GpMascotState.guide => _GpMascotPose(
      translateX: 3.5 * pixelScale * eased,
      rotationDegrees: -0.6 * eased,
    ),
    GpMascotState.celebrate => _GpMascotPose(
      scale: 1 + (math.sin(math.pi * progress) * 0.035),
      translateY: -8 * pixelScale * math.sin(math.pi * progress),
      rotationDegrees: math.sin(progress * math.pi * 2) * 0.8,
    ),
    GpMascotState.error => _GpMascotPose(
      translateX:
          math.sin(progress * math.pi * 3) * 3 * pixelScale * (1 - progress),
      rotationDegrees: math.sin(progress * math.pi * 2) * 0.55 * (1 - progress),
    ),
  };
}

extension _GpMascotStateBehavior on GpMascotState {
  bool get isOneShot {
    return switch (this) {
      GpMascotState.wave ||
      GpMascotState.celebrate ||
      GpMascotState.error => true,
      _ => false,
    };
  }

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
}

extension _GpMascotContextStyle on GpMascotContext {
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
