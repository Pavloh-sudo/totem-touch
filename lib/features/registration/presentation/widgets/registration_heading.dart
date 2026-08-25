import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/mascot/gp_mascot.dart';

class RegistrationHeading extends StatelessWidget {
  const RegistrationHeading({
    required this.title,
    required this.subtitle,
    required this.mascotState,
    super.key,
  });

  final String title;
  final String subtitle;
  final GpMascotState mascotState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 160,
            height: 100,
            child: OverflowBox(
              maxHeight: 150,
              maxWidth: 160,
              alignment: Alignment.center,
              child: _RegistrationCompanion(state: mascotState),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationCompanion extends StatelessWidget {
  const _RegistrationCompanion({required this.state});

  final GpMascotState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GpMascot(
            state: state,
            size: 150,
            enableIdleMotion: false,
            playEntranceAnimation: false,
          ),
          Positioned(
            left: 90,
            top: 68,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 42,
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.graphite,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.carbon.withValues(alpha: 0.14),
                      blurRadius: 5,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 19,
                    color: AppColors.gpaCrimson,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
