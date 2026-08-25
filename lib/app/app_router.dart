import 'package:flutter/material.dart';

import '../features/attract/presentation/attract_page.dart';
import 'kiosk_shell.dart';

abstract final class AppRouter {
  static const attract = '/';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const KioskShell(child: AttractPage()),
    );
  }
}
