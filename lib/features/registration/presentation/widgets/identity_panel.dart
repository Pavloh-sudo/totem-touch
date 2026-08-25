import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/audio/sound_effect.dart';
import '../../../../data/models/visitor_registration.dart';
import '../../../../shared/buttons/gpa_buttons.dart';
import '../../../../shared/inputs/gpa_touch_field.dart';
import '../../../../shared/mascot/gp_mascot.dart';
import 'profile_selector.dart';
import 'registration_heading.dart';

class IdentityPanel extends StatelessWidget {
  const IdentityPanel({
    required this.profile,
    required this.nameController,
    required this.nameFocus,
    required this.nameError,
    required this.nameValid,
    required this.organizationController,
    required this.organizationFocus,
    required this.organizationError,
    required this.identityValid,
    required this.onSelectProfile,
    required this.onNameTap,
    required this.onOrganizationTap,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final VisitorProfile? profile;
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final String? nameError;
  final bool nameValid;
  final TextEditingController organizationController;
  final FocusNode organizationFocus;
  final String? organizationError;
  final bool identityValid;
  final ValueChanged<VisitorProfile> onSelectProfile;
  final VoidCallback onNameTap;
  final VoidCallback onOrganizationTap;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final organizationLabel = profile?.organizationLabel;
    final showOrganization = profile != VisitorProfile.other;

    return Column(
      key: const ValueKey('registration-identity-panel'),
      children: [
        const RegistrationHeading(
          title: 'Primero, queremos conocerte.',
          subtitle:
              'Déjanos tus datos para personalizar la información que encontrarás.',
          mascotState: GpMascotState.thinking,
        ),
        const SizedBox(height: 8),
        ProfileSelector(selected: profile, onSelected: onSelectProfile),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GpaTouchField(
                controller: nameController,
                focusNode: nameFocus,
                label: 'Nombre',
                hint: 'Escribe tu nombre',
                errorText: nameError,
                isValid: nameValid,
                onTap: onNameTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.standard,
                child: showOrganization
                    ? GpaTouchField(
                        key: ValueKey(organizationLabel ?? 'organization'),
                        controller: organizationController,
                        focusNode: organizationFocus,
                        label: organizationLabel ?? 'Empresa / institución',
                        hint: profile == null
                            ? 'Selecciona primero quién eres'
                            : 'Escribe el nombre',
                        enabled: profile != null,
                        errorText: organizationError,
                        isValid: organizationController.text.trim().isNotEmpty,
                        onTap: onOrganizationTap,
                      )
                    : const SizedBox(key: ValueKey('no-organization-field')),
              ),
            ),
          ],
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
                label: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                trailingIcon: true,
                height: 64,
                sound: SoundEffect.selection,
                onPressed: identityValid ? onContinue : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
