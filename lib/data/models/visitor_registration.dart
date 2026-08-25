enum VisitorProfile {
  company('Empresa'),
  institution('Institución'),
  student('Estudiante'),
  professional('Profesional'),
  other('Otro');

  const VisitorProfile(this.label);

  final String label;

  bool get requiresOrganization {
    return switch (this) {
      company || institution || student => true,
      professional || other => false,
    };
  }

  String? get organizationLabel {
    return switch (this) {
      company => 'Empresa',
      institution => 'Institución',
      student => 'Escuela / Institución',
      professional => 'Empresa / Institución (opcional)',
      other => null,
    };
  }
}

class VisitorRegistration {
  const VisitorRegistration({
    required this.profile,
    required this.name,
    required this.organization,
    required this.email,
    required this.phone,
    required this.acceptsInformation,
  });

  final VisitorProfile profile;
  final String name;
  final String organization;
  final String email;
  final String phone;
  final bool acceptsInformation;
}
