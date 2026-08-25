import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum KioskProgressStage { data, interest, detail, done }

class GpaProgressIndicator extends StatelessWidget {
  const GpaProgressIndicator({required this.stage, super.key});

  final KioskProgressStage stage;

  static const _labels = ['Datos', 'Interés', 'Detalle', 'Listo'];

  @override
  Widget build(BuildContext context) {
    final currentIndex = stage.index;

    return Semantics(
      label: 'Progreso: ${_labels[currentIndex]}',
      child: SizedBox(
        width: 344,
        height: 50,
        child: Row(
          children: [
            for (var index = 0; index < _labels.length; index++) ...[
              _ProgressPoint(
                label: _labels[index],
                active: index <= currentIndex,
                current: index == currentIndex,
              ),
              if (index < _labels.length - 1)
                Expanded(
                  child: _ProgressConnector(active: index < currentIndex),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressPoint extends StatelessWidget {
  const _ProgressPoint({
    required this.label,
    required this.active,
    required this.current,
  });

  final String label;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.gpaCrimson : AppColors.steel;

    return SizedBox(
      width: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.standardCurve,
            width: current ? 11 : 8,
            height: current ? 11 : 8,
            decoration: BoxDecoration(
              color: active ? color : AppColors.pureWhite,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.4),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTypography.auxiliary.copyWith(
              color: current ? AppColors.carbon : AppColors.graphite,
              fontSize: 12,
              fontWeight: current ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressConnector extends StatelessWidget {
  const _ProgressConnector({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -9),
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        height: 2,
        decoration: BoxDecoration(
          color: active
              ? AppColors.gpaCrimson
              : AppColors.steel.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
