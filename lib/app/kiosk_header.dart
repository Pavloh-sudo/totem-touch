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
    this.height = KioskConfiguration.headerHeight,
    this.logoSize = 50,
    this.companion,
    this.onLogoHeld,
    super.key,
  });

  final SoundController soundController;
  final KioskProgressStage? progressStage;
  final double height;
  final double logoSize;
  final Widget? companion;
  final VoidCallback? onLogoHeld;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KioskConfiguration.horizontalMargin,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _AdminLogoHold(
                onHeld: onLogoHeld,
                child: Image.asset(
                  AssetPaths.gpaLogo,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  semanticLabel: 'GPA',
                ),
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
            if (companion != null)
              Positioned(
                right: KioskConfiguration.iconControlSize + 18,
                child: companion!,
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

class _AdminLogoHold extends StatefulWidget {
  const _AdminLogoHold({required this.child, required this.onHeld});

  final Widget child;
  final VoidCallback? onHeld;

  @override
  State<_AdminLogoHold> createState() => _AdminLogoHoldState();
}

class _AdminLogoHoldState extends State<_AdminLogoHold> {
  Timer? _holdTimer;

  void _startHold(PointerDownEvent event) {
    if (widget.onHeld == null) return;
    _holdTimer?.cancel();
    _holdTimer = Timer(KioskConfiguration.adminLogoHold, () {
      _holdTimer = null;
      widget.onHeld?.call();
    });
  }

  void _cancelHold(PointerEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _startHold,
      onPointerUp: _cancelHold,
      onPointerCancel: _cancelHold,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }
}
