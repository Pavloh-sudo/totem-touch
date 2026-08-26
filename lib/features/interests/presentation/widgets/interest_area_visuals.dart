import 'package:flutter/material.dart';

import '../../../../core/theme/area_colors.dart';
import '../../../../shared/mascot/gp_mascot.dart';
import '../../domain/interest_area.dart';

extension InterestAreaVisuals on InterestArea {
  Color get accentColor {
    return switch (this) {
      InterestArea.robotics => AreaColors.robotics,
      InterestArea.cutting => AreaColors.cutting,
      InterestArea.manufacturing => AreaColors.manufacturing,
      InterestArea.machinery => AreaColors.machinery,
      InterestArea.software => AreaColors.software,
      InterestArea.careers => AreaColors.careers,
    };
  }

  IconData get icon {
    return switch (this) {
      InterestArea.robotics => Icons.precision_manufacturing_rounded,
      InterestArea.cutting => Icons.content_cut_rounded,
      InterestArea.manufacturing => Icons.factory_rounded,
      InterestArea.machinery => Icons.engineering_rounded,
      InterestArea.software => Icons.memory_rounded,
      InterestArea.careers => Icons.badge_rounded,
    };
  }

  IconData get illustration {
    return switch (this) {
      InterestArea.robotics => Icons.smart_toy_rounded,
      InterestArea.cutting => Icons.bolt_rounded,
      InterestArea.manufacturing => Icons.settings_suggest_rounded,
      InterestArea.machinery => Icons.handyman_rounded,
      InterestArea.software => Icons.laptop_mac_rounded,
      InterestArea.careers => Icons.school_rounded,
    };
  }

  GpMascotContext get mascotContext {
    return switch (this) {
      InterestArea.robotics => GpMascotContext.robotics,
      InterestArea.cutting => GpMascotContext.cutting,
      InterestArea.manufacturing => GpMascotContext.manufacturing,
      InterestArea.machinery => GpMascotContext.machinery,
      InterestArea.software => GpMascotContext.software,
      InterestArea.careers => GpMascotContext.careers,
    };
  }
}
