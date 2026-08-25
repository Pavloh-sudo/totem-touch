import 'dart:async';

import 'package:flutter/material.dart';

import '../core/animations/app_motion.dart';
import '../core/audio/sound_controller.dart';
import '../core/configuration/asset_paths.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../shared/buttons/gpa_buttons.dart';
import '../shared/feedback/gpa_progress_indicator.dart';

class KioskHeader extends StatelessWidget {
  const KioskHeader({
    required this.soundController,
    this.progressStage,
    super.key,
  });

  final SoundController soundController;
  final KioskProgressStage? progressStage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KioskConfiguration.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KioskConfiguration.horizontalMargin,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                AssetPaths.gpaLogo,
                height: 50,
                semanticLabel: 'GPA',
              ),
            ),
            AnimatedSwitcher(
              duration: AppMotion.standard,
              switchInCurve: AppMotion.standardCurve,
              switchOutCurve: AppMotion.standardCurve,
              child: progressStage == null
                  ? const SizedBox.shrink()
                  : GpaProgressIndicator(
                      key: ValueKey(progressStage),
                      stage: progressStage!,
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: soundController,
                builder: (context, child) {
                  final muted = soundController.isMuted;
                  return GpaIconButton(
                    icon: muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    semanticLabel: muted
                        ? 'Activar sonido'
                        : 'Silenciar sonido',
                    onPressed: () {
                      unawaited(soundController.toggleMute());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
