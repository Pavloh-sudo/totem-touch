import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/theme/app_colors.dart';
import 'package:totem_touch/core/theme/app_surfaces.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/core/theme/app_typography.dart';
import 'package:totem_touch/core/theme/area_colors.dart';

void main() {
  group('sistema visual GPA', () {
    test('conserva la paleta principal aprobada', () {
      expect(AppColors.gpaCrimson, const Color(0xFFD92B32));
      expect(AppColors.brightCrimson, const Color(0xFFFF5158));
      expect(AppColors.carbon, const Color(0xFF1D2127));
      expect(AppColors.graphite, const Color(0xFF515A64));
      expect(AppColors.steel, const Color(0xFF9199A2));
      expect(AppColors.porcelain, const Color(0xFFF7F8FA));
      expect(AppColors.techCyan, const Color(0xFF19A7B8));
      expect(AppColors.successGreen, const Color(0xFF24976F));
    });

    test('usa Manrope y la escala pensada para el tótem', () {
      final theme = AppTheme.kiosk;

      expect(theme.textTheme.displayLarge?.fontFamily, AppTypography.family);
      expect(theme.textTheme.displayLarge?.fontSize, 48);
      expect(theme.textTheme.headlineLarge?.fontSize, 34);
      expect(theme.textTheme.bodySmall?.fontSize, 14);
      expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w600);
    });

    test('limita los acentos de áreas a una parte pequeña de la tarjeta', () {
      expect(AreaColors.robotics, AppColors.techCyan);
      expect(AreaColors.careers, AppColors.successGreen);
      expect(AreaColors.maximumCardCoverage, lessThanOrEqualTo(0.15));
      expect(AreaColors.glowOpacity, 0.06);
    });

    test('mantiene las tarjetas ligeras y marca la selección en rojo', () {
      final normal = AppSurfaces.card();
      final selected = AppSurfaces.card(selected: true);

      expect(AppSurfaces.radius, 20);
      expect(normal.borderRadius, BorderRadius.circular(20));
      expect(normal.boxShadow?.single.blurRadius, 12);
      expect((selected.border! as Border).top.color, AppColors.gpaCrimson);
      expect(selected.boxShadow?.first.blurRadius, 18);
    });
  });
}
