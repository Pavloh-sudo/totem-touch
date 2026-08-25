import 'package:flutter/material.dart';

import '../configuration/kiosk_configuration.dart';
import 'app_colors.dart';
import 'app_surfaces.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get kiosk {
    const colorScheme = ColorScheme.light(
      primary: AppColors.gpaCrimson,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.techCyan,
      onSecondary: AppColors.pureWhite,
      surface: AppColors.pureWhite,
      onSurface: AppColors.carbon,
      error: AppColors.gpaCrimson,
      onError: AppColors.pureWhite,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.steel),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.family,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      textTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(color: AppColors.carbon),
      dividerColor: AppColors.steel,
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSurfaces.radius),
          side: BorderSide(color: AppColors.steel.withValues(alpha: 0.28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 20,
        ),
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.field.copyWith(color: AppColors.steel),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.gpaCrimson, width: 2),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.gpaCrimson),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.gpaCrimson,
        selectionColor: Color(0x33D92B32),
        selectionHandleColor: AppColors.gpaCrimson,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            KioskConfiguration.minimumTouchTarget,
            KioskConfiguration.primaryControlHeight,
          ),
          backgroundColor: AppColors.gpaCrimson,
          foregroundColor: AppColors.pureWhite,
          disabledBackgroundColor: AppColors.steel,
          disabledForegroundColor: AppColors.pureWhite,
          textStyle: AppTypography.button,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
