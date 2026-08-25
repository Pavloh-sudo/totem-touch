import 'package:flutter/material.dart';

import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../shared/buttons/gpa_buttons.dart';

class InterestsPage extends StatelessWidget {
  const InterestsPage({
    required this.registration,
    required this.onBack,
    super.key,
  });

  final VisitorRegistration registration;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gpaCrimson,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Qué te interesa conocer?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Aquí comenzará la selección de áreas de GPA.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: 180,
              child: GpaSecondaryButton(
                label: 'Volver',
                icon: Icons.arrow_back_rounded,
                sound: SoundEffect.back,
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
