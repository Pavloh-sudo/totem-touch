abstract final class KioskConfiguration {
  static const String kioskId = String.fromEnvironment(
    'KIOSK_ID',
    defaultValue: 'totem-gpa-01',
  );
  static const String eventId = String.fromEnvironment(
    'EVENT_ID',
    defaultValue: 'evento-gpa',
  );
  static const Duration inactivityTimeout = Duration(
    seconds: int.fromEnvironment('INACTIVITY_SECONDS', defaultValue: 90),
  );
  static const Duration inactivityWarningDuration = Duration(
    seconds: int.fromEnvironment(
      'INACTIVITY_WARNING_SECONDS',
      defaultValue: 10,
    ),
  );
  static const double designWidth = 1024;
  static const double designHeight = 768;
  static const double minimumTouchTarget = 56;
  static const double primaryControlHeight = 64;
  static const double iconControlSize = 64;
  static const double headerHeight = 72;
  static const double attractHeaderHeight = 188;
  static const double attractLogoSize = 180;
  static const double horizontalMargin = 48;
  static const double bottomMargin = 36;
}
