part of '../gp_mascot.dart';

abstract final class _GpMascotTiming {
  static const breathing = Duration(milliseconds: 3200);
  static const entrance = AppMotion.emphasis;
  static const contextChange = AppMotion.standard;

  static Duration reaction(GpMascotState state) {
    return switch (state) {
      GpMascotState.idle => Duration.zero,
      GpMascotState.wave => const Duration(milliseconds: 1100),
      GpMascotState.thinking => const Duration(milliseconds: 600),
      GpMascotState.guide => const Duration(milliseconds: 550),
      GpMascotState.celebrate => const Duration(milliseconds: 1200),
      GpMascotState.error => const Duration(milliseconds: 650),
    };
  }
}

class _GpMascotRandom {
  _GpMascotRandom([math.Random? random]) : _random = random ?? math.Random();

  final math.Random _random;

  Duration get nextBlinkInterval => _between(4000, 7000);
  Duration get nextBlinkDuration => _between(130, 170);
  Duration get doubleBlinkSeparation => _between(120, 220);
  Duration get nextHeadInterval => _between(6500, 12000);
  Duration get nextHeadDuration => _between(500, 700);
  bool get shouldDoubleBlink => _random.nextDouble() < 0.125;

  double get nextHeadAngleDegrees {
    final magnitude = 0.8 + (_random.nextDouble() * 1.2);
    return _random.nextBool() ? magnitude : -magnitude;
  }

  Duration _between(int minimum, int maximum) {
    return Duration(
      milliseconds: minimum + _random.nextInt(maximum - minimum + 1),
    );
  }
}
