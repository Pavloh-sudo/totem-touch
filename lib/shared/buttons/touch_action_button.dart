import 'package:flutter/material.dart';

import '../../core/configuration/kiosk_configuration.dart';

class TouchActionButton extends StatelessWidget {
  const TouchActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), const SizedBox(width: 12), Text(label)],
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: KioskConfiguration.primaryControlHeight,
        minWidth: KioskConfiguration.minimumTouchTarget,
      ),
      child: ElevatedButton(onPressed: onPressed, child: child),
    );
  }
}
