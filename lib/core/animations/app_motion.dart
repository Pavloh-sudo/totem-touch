import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 90);
  static const fast = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
  static const screen = Duration(milliseconds: 280);
  static const emphasis = Duration(milliseconds: 420);
  static const celebration = Duration(milliseconds: 650);
  static const celebrationLong = Duration(milliseconds: 900);

  static const attractToRegistration = Duration(milliseconds: 320);
  static const attractExit = Duration(milliseconds: 140);
  static const registrationEnter = Duration(milliseconds: 220);
  static const attractOverlap = Duration(milliseconds: 60);

  static const touchDown = instant;
  static const touchUp = fast;
  static const ripple = Duration(milliseconds: 320);

  static const Curve standardCurve = Curves.easeOutCubic;
}
