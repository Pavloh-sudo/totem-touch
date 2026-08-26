import 'package:flutter/material.dart';

import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/interest_submission.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/mascot/gp_mascot.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({
    required this.submission,
    required this.onFinish,
    super.key,
  });

  final InterestSubmission submission;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.successGreen, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Gracias, ${submission.registration.name}!',
                style: AppTypography.hero.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 14),
              Text('Registramos tu interés en:', style: AppTypography.body),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: AppSurfaces.card(selected: true),
                child: Text(
                  submission.finalInterest,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.gpaCrimson,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 220,
                child: GpaPrimaryButton(
                  label: 'Finalizar',
                  icon: Icons.arrow_forward_rounded,
                  trailingIcon: true,
                  sound: SoundEffect.tap,
                  onPressed: onFinish,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: GpMascot(
              key: const ValueKey('success-mascot'),
              size: 300,
              state: GpMascotState.celebrate,
            ),
          ),
        ),
      ],
    );
  }
}
