import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const family = 'Manrope';

  static const hero = TextStyle(
    fontFamily: family,
    color: AppColors.textPrimary,
    fontSize: 48,
    height: 1.08,
    fontWeight: FontWeight.w700,
  );

  static const screenTitle = TextStyle(
    fontFamily: family,
    color: AppColors.textPrimary,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const subtitle = TextStyle(
    fontFamily: family,
    color: AppColors.textPrimary,
    fontSize: 19,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontFamily: family,
    color: AppColors.textSecondary,
    fontSize: 18,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const field = TextStyle(
    fontFamily: family,
    color: AppColors.textPrimary,
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    fontFamily: family,
    color: AppColors.textPrimary,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const button = TextStyle(
    fontFamily: family,
    color: AppColors.pureWhite,
    fontSize: 19,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static const auxiliary = TextStyle(
    fontFamily: family,
    color: AppColors.textSecondary,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const textTheme = TextTheme(
    displayLarge: hero,
    headlineLarge: screenTitle,
    headlineMedium: screenTitle,
    titleLarge: subtitle,
    titleMedium: label,
    labelLarge: button,
    labelMedium: label,
    bodyLarge: body,
    bodyMedium: label,
    bodySmall: auxiliary,
  );
}
