abstract final class AssetPaths {
  static const gpaLogo = 'assets/branding/gpa_logo.png';

  static const _mascotRoot = 'assets/mascot/gp';

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
  ];
}
