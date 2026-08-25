import 'package:flutter/material.dart';

import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/buttons/gpa_buttons.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
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
            Text('Cuéntanos un poco sobre ti', style: textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              'Empecemos con tus datos para saber cómo podemos ayudarte.',
              style: textTheme.bodyLarge,
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
