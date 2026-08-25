import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

class TotemTouchApp extends StatelessWidget {
  const TotemTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tótem Touch GPA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.kiosk,
      initialRoute: AppRouter.attract,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
