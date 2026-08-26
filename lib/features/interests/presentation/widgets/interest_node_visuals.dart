import 'package:flutter/material.dart';

import '../../../../core/theme/area_colors.dart';
import '../../../../shared/mascot/gp_mascot.dart';
import '../../domain/interest_node.dart';

extension InterestNodeVisuals on InterestNode {
  Color get accentColor => accent.color;
  IconData get iconData => icon.data;
  IconData get illustrationData => illustration.data;
}

extension InterestAccentVisuals on InterestAccent {
  Color get color {
    return switch (this) {
      InterestAccent.robotics => AreaColors.robotics,
      InterestAccent.cutting => AreaColors.cutting,
      InterestAccent.manufacturing => AreaColors.manufacturing,
      InterestAccent.machinery => AreaColors.machinery,
      InterestAccent.software => AreaColors.software,
      InterestAccent.careers => AreaColors.careers,
    };
  }
}

extension InterestIconVisuals on InterestIcon {
  IconData get data {
    return switch (this) {
      InterestIcon.robotics => Icons.precision_manufacturing_rounded,
      InterestIcon.cutting => Icons.content_cut_rounded,
      InterestIcon.manufacturing => Icons.factory_rounded,
      InterestIcon.machinery => Icons.engineering_rounded,
      InterestIcon.software => Icons.memory_rounded,
      InterestIcon.careers => Icons.badge_rounded,
    };
  }
}

extension InterestIllustrationVisuals on InterestIllustration {
  IconData get data {
    return switch (this) {
      InterestIllustration.robot => Icons.smart_toy_rounded,
      InterestIllustration.energy => Icons.bolt_rounded,
      InterestIllustration.production => Icons.settings_suggest_rounded,
      InterestIllustration.tools => Icons.handyman_rounded,
      InterestIllustration.computer => Icons.laptop_mac_rounded,
      InterestIllustration.education => Icons.school_rounded,
    };
  }
}

extension InterestMascotOutfitVisuals on InterestMascotOutfit? {
  GpMascotContext get context {
    return switch (this) {
      InterestMascotOutfit.robotics => GpMascotContext.robotics,
      InterestMascotOutfit.cutting => GpMascotContext.cutting,
      InterestMascotOutfit.manufacturing => GpMascotContext.manufacturing,
      InterestMascotOutfit.machinery => GpMascotContext.machinery,
      InterestMascotOutfit.software => GpMascotContext.software,
      InterestMascotOutfit.careers => GpMascotContext.careers,
      null => GpMascotContext.defaultOutfit,
    };
  }
}
