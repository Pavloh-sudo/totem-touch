import 'package:flutter/material.dart';

import '../core/animations/app_motion.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../features/attract/presentation/attract_page.dart';
import '../features/registration/presentation/registration_page.dart';
import '../shared/feedback/gpa_progress_indicator.dart';
import 'kiosk_shell.dart';

abstract final class AppRouter {
  static const attract = '/';
  static const registration = '/registro';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      registration => _registrationRoute(settings),
      _ => _attractRoute(settings),
    };
  }

  static Route<void> _attractRoute(RouteSettings settings) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: AppMotion.attractToRegistration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return KioskShell(
          headerHeight: KioskConfiguration.attractHeaderHeight,
          logoSize: KioskConfiguration.attractLogoSize,
          inactivityTimeout: null,
          child: AttractPage(
            onStart: () async {
              await Navigator.of(context).pushNamed(registration);
            },
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _AttractExitTransition(
          animation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  static Route<void> _registrationRoute(RouteSettings settings) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: AppMotion.attractToRegistration,
      reverseTransitionDuration: AppMotion.attractToRegistration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return KioskShell(
          progressStage: KioskProgressStage.data,
          child: RegistrationPage(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _RegistrationEnterTransition(animation: animation, child: child);
      },
    );
  }
}

class _AttractExitTransition extends StatelessWidget {
  const _AttractExitTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final exitEnd =
        AppMotion.attractExit.inMilliseconds /
        AppMotion.attractToRegistration.inMilliseconds;
    final progress = CurvedAnimation(
      parent: animation,
      curve: Interval(0, exitEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) {
        return Opacity(
          key: const ValueKey('attract-exit-opacity'),
          opacity: 1 - progress.value,
          child: Transform.translate(
            offset: Offset(0, -8 * progress.value),
            child: child,
          ),
        );
      },
    );
  }
}

class _RegistrationEnterTransition extends StatelessWidget {
  const _RegistrationEnterTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final routeMilliseconds = AppMotion.attractToRegistration.inMilliseconds;
    final entryStart =
        (AppMotion.attractExit - AppMotion.attractOverlap).inMilliseconds /
        routeMilliseconds;
    final entryEnd =
        (AppMotion.attractExit -
                AppMotion.attractOverlap +
                AppMotion.registrationEnter)
            .inMilliseconds /
        routeMilliseconds;
    final progress = CurvedAnimation(
      parent: animation,
      curve: Interval(entryStart, entryEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) {
        return Opacity(
          key: const ValueKey('registration-entry-opacity'),
          opacity: progress.value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - progress.value)),
            child: child,
          ),
        );
      },
    );
  }
}
