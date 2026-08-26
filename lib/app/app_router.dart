import 'package:flutter/material.dart';

import '../core/animations/app_motion.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../core/session/registration_session_controller.dart';
import '../data/local/memory_interest_submission_repository.dart';
import '../data/models/registration_session.dart';
import '../data/models/visitor_registration.dart';
import '../features/attract/presentation/attract_page.dart';
import '../features/interests/presentation/interests_screen.dart';
import '../features/registration/presentation/registration_page.dart';
import '../features/success/presentation/success_page.dart';
import '../shared/feedback/gpa_progress_indicator.dart';
import 'kiosk_shell.dart';

abstract final class AppRouter {
  static const attract = '/';
  static const registration = '/registro';
  static const interests = '/intereses';
  static const success = '/gracias';

  static final _interestRepository = MemoryInterestSubmissionRepository();

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      registration => _registrationRoute(settings),
      interests => _interestsRoute(settings),
      success => _successRoute(settings),
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
              RegistrationSessionScope.of(context).begin();
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
          onInactivityWarning: () => _closeTransientRoute(context),
          onSessionExpired: () => _resetSession(context),
          child: RegistrationPage(
            onBack: () {
              RegistrationSessionScope.of(context).resetForNextVisitor();
              Navigator.of(context).pop();
            },
            onContinue: (registrationData) async {
              RegistrationSessionScope.of(
                context,
              ).setRegistration(registrationData);
              await Navigator.of(
                context,
              ).pushNamed(interests, arguments: registrationData);
            },
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _RegistrationEnterTransition(animation: animation, child: child);
      },
    );
  }

  static Route<void> _interestsRoute(RouteSettings settings) {
    final registrationData = settings.arguments;
    if (registrationData is! VisitorRegistration) {
      return _registrationRoute(const RouteSettings(name: registration));
    }
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: AppMotion.screen,
      reverseTransitionDuration: AppMotion.screen,
      pageBuilder: (context, animation, secondaryAnimation) {
        return InterestsScreen(
          sessionController: RegistrationSessionScope.of(context),
          repository: _interestRepository,
          onBack: () => Navigator.of(context).pop(),
          onSessionExpired: () => _resetSession(context),
          onCompleted: (submission) async {
            await Navigator.of(
              context,
            ).pushReplacementNamed(success, arguments: submission);
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final progress = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standardCurve,
        );
        return FadeTransition(
          opacity: progress,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 14 / 768),
              end: Offset.zero,
            ).animate(progress),
            child: child,
          ),
        );
      },
    );
  }

  static Route<void> _successRoute(RouteSettings settings) {
    final submission = settings.arguments;
    if (submission is! RegistrationSession) return _attractRoute(settings);

    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: AppMotion.screen,
      reverseTransitionDuration: AppMotion.screen,
      pageBuilder: (context, animation, secondaryAnimation) {
        return KioskShell(
          progressStage: KioskProgressStage.done,
          onSessionExpired: () => _resetSession(context),
          child: SuccessPage(
            submission: submission,
            onFinish: () {
              _resetSession(context);
            },
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final progress = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standardCurve,
        );
        return FadeTransition(
          opacity: progress,
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(progress),
            child: child,
          ),
        );
      },
    );
  }

  static void _resetSession(BuildContext context) {
    RegistrationSessionScope.of(context).resetForNextVisitor();
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static void _closeTransientRoute(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) Navigator.of(context).pop();
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
