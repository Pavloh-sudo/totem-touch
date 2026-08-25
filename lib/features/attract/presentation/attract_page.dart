import 'package:flutter/material.dart';

import '../../../core/configuration/asset_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/cards/gpa_surface_card.dart';

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
                    color: AppColors.gpaCrimson,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Descubre todo lo que hacemos en GPA',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Conoce nuestras áreas, proyectos y oportunidades.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                const _WelcomeMessage(),
              ],
            ),
          ),
          const SizedBox(width: 56),
          Expanded(
            flex: 4,
            child: GpaSurfaceCard(
              child: Center(
                child: Image.asset(
                  AssetPaths.gpaLogo,
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

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return GpaSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.techCyan, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Todo en un solo lugar',
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
