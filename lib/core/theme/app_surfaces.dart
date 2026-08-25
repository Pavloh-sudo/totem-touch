import 'package:flutter/material.dart';

import '../animations/app_motion.dart';
import 'app_colors.dart';

abstract final class AppSurfaces {
  static const double radius = 20;
  static const Duration transitionDuration = AppMotion.standard;

  static BoxDecoration card({bool selected = false}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected
            ? AppColors.gpaCrimson
            : AppColors.steel.withValues(alpha: 0.18),
        width: selected ? 1.5 : 1,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: AppColors.brightCrimson.withValues(alpha: 0.08),
                blurRadius: 18,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppColors.carbon.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : [
              BoxShadow(
                color: AppColors.carbon.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
    );
  }
}
