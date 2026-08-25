import 'package:flutter/material.dart';

import '../core/animations/app_motion.dart';
import '../features/attract/presentation/attract_page.dart';
import 'kiosk_shell.dart';

abstract final class AppRouter {
  static const attract = '/';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: AppMotion.screen,
      reverseTransitionDuration: AppMotion.standard,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const KioskShell(child: AttractPage());
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standardCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.015, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
