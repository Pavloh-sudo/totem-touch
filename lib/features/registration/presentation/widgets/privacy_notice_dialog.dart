import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_controller.dart';
import '../../../../core/audio/sound_effect.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/buttons/gpa_buttons.dart';

Future<void> showGpaPrivacyNotice(BuildContext context) async {
  final controller = SoundControllerScope.maybeOf(context);
  if (controller != null) unawaited(controller.play(SoundEffect.tap));

  await showDialog<void>(
    context: context,
    barrierColor: AppColors.carbon.withValues(alpha: 0.42),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aviso de privacidad',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 18),
                Text(
                  'Este espacio queda listo para integrar el aviso de '
                  'privacidad autorizado por Grupo GPA.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 170,
                    child: GpaPrimaryButton(
                      label: 'Entendido',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
