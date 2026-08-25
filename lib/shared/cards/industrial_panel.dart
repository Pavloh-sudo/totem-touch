import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class IndustrialPanel extends StatelessWidget {
  const IndustrialPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.steel.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.carbon.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
