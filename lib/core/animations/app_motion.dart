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

  static const fieldFocus = Duration(milliseconds: 140);
  static const fieldValidCheck = Duration(milliseconds: 140);
  static const fieldError = Duration(milliseconds: 260);
  static const checkboxContainer = Duration(milliseconds: 160);
  static const checkboxCheck = Duration(milliseconds: 190);
  static const keyboardShow = Duration(milliseconds: 220);
  static const keyboardHide = Duration(milliseconds: 180);
  static const keyboardBackspaceHold = Duration(milliseconds: 450);
  static const keyboardBackspaceRepeat = Duration(milliseconds: 80);
  static const keyboardToScreen = Duration(milliseconds: 100);

  static const touchDown = instant;
  static const touchUp = fast;
  static const ripple = Duration(milliseconds: 320);

  static const Curve standardCurve = Curves.easeOutCubic;
}
