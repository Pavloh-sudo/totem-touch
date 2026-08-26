enum InterestArea {
  robotics('Robótica & Automatización', 'Cobots, automatización e inspección.'),
  cutting('Sistemas de Corte', 'Plasma, láser y waterjet.'),
  manufacturing(
    'Fabricación Avanzada',
    'Procesos y soluciones de fabricación.',
  ),
  machinery('Maquinaria a la Medida', 'Ingeniería especializada.'),
  software('Software Industrial', 'Soluciones digitales para industria.'),
  careers('Vacantes & Estadías', 'Forma parte de GPA.');

  const InterestArea(this.title, this.description);

  final String title;
  final String description;
}
