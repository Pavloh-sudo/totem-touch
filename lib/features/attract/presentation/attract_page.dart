import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/cards/industrial_panel.dart';

class AttractPage extends StatelessWidget {
  const AttractPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(56),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.gpaRed,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Tótem interactivo\nGPA', style: textTheme.displayLarge),
                const SizedBox(height: 24),
                Text(
                  'Base del proyecto lista para comenzar con las pantallas.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                const _ProjectStatus(),
              ],
            ),
          ),
          const SizedBox(width: 56),
          Expanded(
            flex: 4,
            child: IndustrialPanel(
              child: Center(
                child: Image.asset(
                  'assets/branding/logo-gpa.png',
                  width: 270,
                  semanticLabel: 'Logo de GPA',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectStatus extends StatelessWidget {
  const _ProjectStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steel.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.gpaRed, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Flutter Web · 1024 × 768',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
