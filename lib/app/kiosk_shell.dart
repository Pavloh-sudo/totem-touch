import 'package:flutter/material.dart';

import '../core/configuration/kiosk_configuration.dart';
import '../core/theme/app_colors.dart';
import '../shared/widgets/technical_background.dart';

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
              child: TechnicalBackground(child: SafeArea(child: child)),
            ),
          ),
        ),
      ),
    );
  }
}
