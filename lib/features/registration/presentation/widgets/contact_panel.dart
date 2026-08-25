import 'package:flutter/material.dart';

import '../../../../core/audio/sound_effect.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/buttons/gpa_buttons.dart';
import '../../../../shared/inputs/gpa_consent_checkbox.dart';
import '../../../../shared/inputs/gpa_touch_field.dart';
import '../../../../shared/mascot/gp_mascot.dart';
import 'registration_heading.dart';

class ContactPanel extends StatelessWidget {
  const ContactPanel({
    required this.emailController,
    required this.emailFocus,
    required this.emailError,
    required this.emailValid,
    required this.phoneController,
    required this.phoneFocus,
    required this.phoneError,
    required this.phoneValid,
    required this.acceptsInformation,
    required this.openingNextScreen,
    required this.contactValid,
    required this.onEmailTap,
    required this.onPhoneTap,
    required this.onConsentChanged,
    required this.onPrivacyTap,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final TextEditingController emailController;
  final FocusNode emailFocus;
  final String? emailError;
  final bool emailValid;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? phoneError;
  final bool phoneValid;
  final bool acceptsInformation;
  final bool openingNextScreen;
  final bool contactValid;
  final VoidCallback onEmailTap;
  final VoidCallback onPhoneTap;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback onPrivacyTap;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('registration-contact-panel'),
      children: [
        const RegistrationHeading(
          title: 'Queremos conocerte',
          subtitle: '¿Dónde podemos compartirte información?',
          mascotState: GpMascotState.guide,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GpaTouchField(
                controller: emailController,
                focusNode: emailFocus,
                label: 'Correo electrónico',
                hint: 'nombre@correo.com',
                errorText: emailError,
                isValid: emailValid,
                onTap: onEmailTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GpaTouchField(
                controller: phoneController,
                focusNode: phoneFocus,
                label: 'Teléfono',
                hint: '10 dígitos',
                errorText: phoneError,
                isValid: phoneValid,
                onTap: onPhoneTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GpaConsentCheckbox(
          value: acceptsInformation,
          onChanged: onConsentChanged,
        ),
        SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onPrivacyTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gpaCrimson,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: AppTypography.auxiliary.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: const Text('Consulta nuestro aviso de privacidad'),
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 170,
              child: GpaSecondaryButton(
                label: 'Volver',
                icon: Icons.arrow_back_rounded,
                height: 64,
                sound: SoundEffect.back,
                onPressed: onBack,
              ),
            ),
            SizedBox(
              width: 220,
              child: GpaPrimaryButton(
                label: openingNextScreen ? 'Continuando' : 'Continuar',
                icon: Icons.arrow_forward_rounded,
                trailingIcon: true,
                height: 64,
                state: openingNextScreen
                    ? GpaButtonState.loading
                    : GpaButtonState.normal,
                sound: SoundEffect.selection,
                onPressed: contactValid && !openingNextScreen
                    ? onContinue
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
