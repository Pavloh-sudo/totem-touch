import 'package:flutter/material.dart';

import '../core/configuration/kiosk_configuration.dart';
import '../core/theme/app_colors.dart';

class KioskShell extends StatelessWidget {
  const KioskShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: AppColors.outerBackground,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: KioskConfiguration.designWidth,
              height: KioskConfiguration.designHeight,
              child: ColoredBox(
                color: AppColors.background,
                child: SafeArea(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
