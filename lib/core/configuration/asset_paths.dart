abstract final class AssetPaths {
  static const gpaLogo = 'assets/branding/gpa_logo.png';

  static const _mascotRoot = 'assets/mascot/gp';
  static const interestIllustrations = [
    'assets/illustrations/robotics/interest_card.png',
    'assets/illustrations/cutting/interest_card.png',
    'assets/illustrations/manufacturing/interest_card.png',
    'assets/illustrations/machinery/interest_card.png',
    'assets/illustrations/software/interest_card.png',
    'assets/illustrations/careers/interest_card.png',
  ];

  static const interestDetailIllustrations = [
    'assets/illustrations/robotics/automatizacion_linea_produccion.png',
    'assets/illustrations/robotics/automatizacion_robots.png',
    'assets/illustrations/robotics/automatizacion_cobots.png',
    'assets/illustrations/robotics/inspeccion_inteligente.png',
    'assets/illustrations/robotics/celdas_corte_plasma.png',
    'assets/illustrations/robotics/celdas_corte_laser.png',
    'assets/illustrations/robotics/celdas_corte_waterjet.png',
    'assets/illustrations/robotics/industria_salud_biomedica.png',
    'assets/illustrations/robotics/industria_quimica.png',
    'assets/illustrations/robotics/industria_aeroespacial.png',
    'assets/illustrations/robotics/industria_educacion.png',
    'assets/illustrations/cutting/corte_manual_plasma.png',
    'assets/illustrations/cutting/corte_plasma.png',
    'assets/illustrations/cutting/corte_waterjet.png',
    'assets/illustrations/cutting/corte_laser.png',
    'assets/illustrations/manufacturing/diseno_industrial.png',
    'assets/illustrations/manufacturing/software_industrial_medida.png',
    'assets/illustrations/manufacturing/racks_dollies_trolleys.png',
    'assets/illustrations/manufacturing/piezas_metalmecanicas_serie.png',
    'assets/illustrations/manufacturing/housing_sheet_metal.png',
    'assets/illustrations/manufacturing/maquinados_especiales.png',
    'assets/illustrations/manufacturing/servicios_industriales.png',
    'assets/illustrations/manufacturing/estructuras_metalmecanicas.png',
    'assets/illustrations/machinery/maquinaria_metalmecanica.png',
    'assets/illustrations/machinery/maquinaria_alimentos.png',
    'assets/illustrations/machinery/maquinaria_construccion.png',
    'assets/illustrations/machinery/maquinaria_automotriz.png',
    'assets/illustrations/machinery/maquinaria_agricola.png',
    'assets/illustrations/machinery/maquinaria_energia.png',
    'assets/illustrations/machinery/maquinaria_transporte.png',
    'assets/illustrations/software/tableros_informacion.png',
    'assets/illustrations/software/big_data_ia.png',
    'assets/illustrations/software/apps_industriales.png',
    'assets/illustrations/software/aplicativos.png',
    'assets/illustrations/software/sistemas_web.png',
    'assets/illustrations/careers/vacantes_administrativas_financieras.png',
    'assets/illustrations/careers/vacantes_contables.png',
    'assets/illustrations/careers/vacantes_ingenieria.png',
    'assets/illustrations/careers/vacantes_operacion_produccion.png',
    'assets/illustrations/careers/vacantes_capital_humano.png',
    'assets/illustrations/careers/becario_trainee.png',
  ];

  static const initialImages = [
    gpaLogo,
    '$_mascotRoot/body.png',
    '$_mascotRoot/head.png',
    '$_mascotRoot/eyes_open.png',
    '$_mascotRoot/eyes_closed.png',
    '$_mascotRoot/mouth_smile.png',
    '$_mascotRoot/arm_left_idle.png',
    '$_mascotRoot/arm_right_idle.png',
    '$_mascotRoot/arm_right_wave.png',
    '$_mascotRoot/shadow.png',
  ];

  static const deferredImages = [
    '$_mascotRoot/mouth_neutral.png',
    '$_mascotRoot/mouth_thinking.png',
    '$_mascotRoot/mouth_error.png',
    '$_mascotRoot/arm_right_guide.png',
    '$_mascotRoot/arm_left_celebrate.png',
    '$_mascotRoot/arm_right_celebrate.png',
    ...interestIllustrations,
    ...interestDetailIllustrations,
  ];
}
