import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/area_colors.dart';

part 'src/gp_mascot_artwork.dart';
part 'src/gp_mascot_assets.dart';
part 'src/gp_mascot_context_accessories.dart';
part 'src/gp_mascot_motion.dart';
part 'src/gp_mascot_state.dart';
part 'src/gp_mascot_timing.dart';

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

class GpMascot extends StatefulWidget {
  const GpMascot({
    this.artwork,
    this.state = GpMascotState.idle,
    this.mascotContext = GpMascotContext.defaultOutfit,
    this.size = 240,
    this.alignment = Alignment.bottomCenter,
    this.enableIdleMotion = true,
    this.playEntranceAnimation = true,
    super.key,
  });

  final Widget? artwork;
  final GpMascotState state;
  final GpMascotContext mascotContext;
  final double size;
  final AlignmentGeometry alignment;
  final bool enableIdleMotion;
  final bool playEntranceAnimation;

  @visibleForTesting
  static Widget layeredArtworkForTesting({
    required Widget body,
    required Widget head,
    required Widget openEyes,
    required Widget closedEyes,
    Widget? headAccessories,
    Widget? foreground,
    Widget? shadow,
  }) {
    return _GpArtworkLayers(
      body: body,
      head: head,
      openEyes: openEyes,
      closedEyes: closedEyes,
      mouthNeutral: null,
      mouthSmile: null,
      mouthThinking: null,
      mouthError: null,
      armLeftIdle: null,
      armRightIdle: null,
      armRightWave: null,
      armRightGuide: null,
      armLeftCelebrate: null,
      armRightCelebrate: null,
      headAccessories: headAccessories,
      foreground: foreground,
      shadow: shadow,
      headAlignment: _GpAssetRig.headAlignment,
      armLeftAlignment: _GpAssetRig.armLeftAlignment,
      armRightAlignment: _GpAssetRig.armRightAlignment,
    );
  }

  @override
  State<GpMascot> createState() => _GpMascotState();
}
