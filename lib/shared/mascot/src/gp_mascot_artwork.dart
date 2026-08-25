part of '../gp_mascot.dart';

class _GpArtworkLayers extends StatelessWidget {
  const _GpArtworkLayers({
    required this.body,
    required this.head,
    required this.openEyes,
    required this.closedEyes,
    required this.mouthNeutral,
    required this.mouthSmile,
    required this.mouthThinking,
    required this.mouthError,
    required this.armLeftIdle,
    required this.armRightIdle,
    required this.armRightWave,
    required this.armRightGuide,
    required this.armLeftCelebrate,
    required this.armRightCelebrate,
    required this.headAccessories,
    required this.foreground,
    required this.shadow,
    required this.headAlignment,
    required this.armLeftAlignment,
    required this.armRightAlignment,
  });

  final Widget body;
  final Widget? head;
  final Widget? openEyes;
  final Widget? closedEyes;
  final Widget? mouthNeutral;
  final Widget? mouthSmile;
  final Widget? mouthThinking;
  final Widget? mouthError;
  final Widget? armLeftIdle;
  final Widget? armRightIdle;
  final Widget? armRightWave;
  final Widget? armRightGuide;
  final Widget? armLeftCelebrate;
  final Widget? armRightCelebrate;
  final Widget? headAccessories;
  final Widget? foreground;
  final Widget? shadow;
  final Alignment headAlignment;
  final Alignment armLeftAlignment;
  final Alignment armRightAlignment;

  bool get hasArticulatedPoses {
    return armRightWave != null ||
        armRightGuide != null ||
        armLeftCelebrate != null ||
        armRightCelebrate != null ||
        mouthThinking != null ||
        mouthError != null;
  }

  Widget animated({
    required GpMascotState state,
    required double reactionProgress,
    required bool reduceMotion,
    required bool eyesClosed,
    required double headAngleRadians,
    required double shadowScale,
    required double shadowOpacity,
  }) {
    final persistentWeight = Curves.easeOutCubic.transform(reactionProgress);
    final oneShotWeight = reduceMotion
        ? 1.0
        : math.sin(math.pi * reactionProgress).clamp(0.0, 1.0);

    final poseWeight = switch (state) {
      GpMascotState.wave ||
      GpMascotState.celebrate ||
      GpMascotState.error => oneShotWeight,
      GpMascotState.thinking || GpMascotState.guide => persistentWeight,
      GpMascotState.idle => 0.0,
    };

    final leftArmTarget = switch (state) {
      GpMascotState.celebrate => armLeftCelebrate,
      _ => null,
    };
    final rightArmTarget = switch (state) {
      GpMascotState.wave => armRightWave,
      GpMascotState.guide => armRightGuide,
      GpMascotState.celebrate => armRightCelebrate,
      _ => null,
    };
    final mouthTarget = switch (state) {
      GpMascotState.wave || GpMascotState.celebrate => mouthSmile,
      GpMascotState.thinking => mouthThinking,
      GpMascotState.error => mouthError,
      _ => null,
    };

    final armPulse = reduceMotion
        ? 0.0
        : math.sin(reactionProgress * math.pi * 5) * poseWeight;
    final leftArmAngle = switch (state) {
      GpMascotState.celebrate => -armPulse * 3 * math.pi / 180,
      _ => 0.0,
    };
    final rightArmAngle = switch (state) {
      GpMascotState.wave => armPulse * 5 * math.pi / 180,
      GpMascotState.guide => -persistentWeight * 2 * math.pi / 180,
      GpMascotState.celebrate => armPulse * 3 * math.pi / 180,
      _ => 0.0,
    };
    final stateHeadAngle = switch (state) {
      GpMascotState.thinking => -persistentWeight * 2.5 * math.pi / 180,
      GpMascotState.guide => persistentWeight * 0.8 * math.pi / 180,
      GpMascotState.error when !reduceMotion =>
        math.sin(reactionProgress * math.pi * 3) *
            oneShotWeight *
            0.8 *
            math.pi /
            180,
      _ => 0.0,
    };

    final leftArm = _crossfade(armLeftIdle, leftArmTarget, poseWeight);
    final rightArm = _crossfade(armRightIdle, rightArmTarget, poseWeight);
    final mouth = _crossfade(mouthNeutral, mouthTarget, poseWeight);

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        if (shadow != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: shadowOpacity,
              child: Transform.scale(
                scaleX: shadowScale,
                scaleY: 1,
                child: shadow,
              ),
            ),
          ),
        if (leftArm != null)
          Transform.rotate(
            angle: leftArmAngle,
            alignment: armLeftAlignment,
            child: leftArm,
          ),
        if (rightArm != null)
          Transform.rotate(
            angle: rightArmAngle,
            alignment: armRightAlignment,
            child: rightArm,
          ),
        body,
        if (head != null ||
            openEyes != null ||
            mouth != null ||
            headAccessories != null)
          Transform.rotate(
            angle: headAngleRadians + stateHeadAngle,
            alignment: headAlignment,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ?head,
                if (!eyesClosed) ?openEyes,
                if (eyesClosed) ?closedEyes,
                ?mouth,
                ?headAccessories,
              ],
            ),
          ),
        ?foreground,
      ],
    );
  }

  Widget? _crossfade(Widget? base, Widget? target, double weight) {
    if (base == null) return target;
    if (target == null || weight <= 0) return base;
    if (weight >= 1) return target;

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(opacity: 1 - weight, child: base),
        Opacity(opacity: weight, child: target),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return animated(
      state: GpMascotState.idle,
      reactionProgress: 0,
      reduceMotion: false,
      eyesClosed: false,
      headAngleRadians: 0,
      shadowScale: 1,
      shadowOpacity: 1,
    );
  }
}
