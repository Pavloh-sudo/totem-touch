import 'dart:async';

import 'package:flutter/material.dart';

import '../core/audio/sound_controller.dart';
import '../core/audio/sound_effect.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../core/theme/app_colors.dart';
import '../shared/feedback/gpa_progress_indicator.dart';
import '../shared/widgets/technical_background.dart';
import 'kiosk_header.dart';

class KioskShell extends StatefulWidget {
  const KioskShell({
    required this.child,
    this.progressStage,
    this.inactivityTimeout = const Duration(minutes: 2),
    this.warningBeforeTimeout = const Duration(seconds: 15),
    this.onInactivityWarning,
    this.onSessionExpired,
    this.soundController,
    this.headerHeight = KioskConfiguration.headerHeight,
    this.logoSize = 50,
    super.key,
  });

  final Widget child;
  final KioskProgressStage? progressStage;
  final Duration? inactivityTimeout;
  final Duration warningBeforeTimeout;
  final VoidCallback? onInactivityWarning;
  final VoidCallback? onSessionExpired;
  final SoundController? soundController;
  final double headerHeight;
  final double logoSize;

  @override
  State<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends State<KioskShell> {
  late final SoundController _soundController;
  Timer? _warningTimer;
  Timer? _expirationTimer;

  @override
  void initState() {
    super.initState();
    _soundController = widget.soundController ?? SoundController.instance;
    unawaited(_soundController.preload());
    _scheduleInactivity();
  }

  @override
  void didUpdateWidget(covariant KioskShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inactivityTimeout != widget.inactivityTimeout ||
        oldWidget.warningBeforeTimeout != widget.warningBeforeTimeout) {
      _scheduleInactivity();
    }
  }

  void _registerActivity(PointerDownEvent event) {
    _scheduleInactivity();
  }

  void _scheduleInactivity() {
    _warningTimer?.cancel();
    _expirationTimer?.cancel();

    final timeout = widget.inactivityTimeout;
    if (timeout == null) return;

    final warningDelay = timeout - widget.warningBeforeTimeout;
    if (warningDelay > Duration.zero) {
      _warningTimer = Timer(warningDelay, _warnAboutInactivity);
    }
    _expirationTimer = Timer(timeout, _expireSession);
  }

  void _warnAboutInactivity() {
    unawaited(_soundController.play(SoundEffect.warning));
    widget.onInactivityWarning?.call();
  }

  void _expireSession() {
    if (!mounted) return;

    if (widget.onSessionExpired case final callback?) {
      callback();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    _scheduleInactivity();
  }

  @override
  Widget build(BuildContext context) {
    return SoundControllerScope(
      controller: _soundController,
      child: Scaffold(
        body: ColoredBox(
          color: AppColors.outerBackground,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: KioskConfiguration.designWidth,
                height: KioskConfiguration.designHeight,
                child: TechnicalBackground(
                  child: SafeArea(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: _registerActivity,
                      child: FocusTraversalGroup(
                        child: Column(
                          children: [
                            KioskHeader(
                              soundController: _soundController,
                              progressStage: widget.progressStage,
                              height: widget.headerHeight,
                              logoSize: widget.logoSize,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: KioskConfiguration.horizontalMargin,
                                  right: KioskConfiguration.horizontalMargin,
                                  bottom: KioskConfiguration.bottomMargin,
                                ),
                                child: widget.child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    _expirationTimer?.cancel();
    super.dispose();
  }
}
