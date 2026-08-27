import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 90);
  static const fast = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
  static const graceful = Duration(milliseconds: 320);
  static const screen = Duration(milliseconds: 360);
  static const emphasis = Duration(milliseconds: 520);
  static const celebration = Duration(milliseconds: 780);
  static const celebrationLong = Duration(milliseconds: 1050);

  static const attractToRegistration = Duration(milliseconds: 390);
  static const attractExit = Duration(milliseconds: 170);
  static const registrationEnter = Duration(milliseconds: 280);
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

  static const interestCardEntry = Duration(milliseconds: 300);
  static const interestCardStagger = Duration(milliseconds: 45);
  static const interestSelected = Duration(milliseconds: 180);
  static const interestUnselected = Duration(milliseconds: 230);
  static const interestFeedback = Duration(milliseconds: 420);
  static const interestSaving = Duration(milliseconds: 560);

  static const successCircle = Duration(milliseconds: 360);
  static const successCheck = Duration(milliseconds: 300);
  static const successConfetti = Duration(milliseconds: 900);
  static const successSoundDelay = Duration(milliseconds: 120);
  static const successVisible = Duration(seconds: 13);
  static const successCountdownDelay = Duration(seconds: 8);

  static const touchDown = instant;
  static const touchUp = fast;
  static const ripple = Duration(milliseconds: 320);

  static const Curve standardCurve = Curves.easeOutCubic;
}
