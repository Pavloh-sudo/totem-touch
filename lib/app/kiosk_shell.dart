import 'dart:async';

import 'package:flutter/material.dart';

import '../core/animations/app_motion.dart';
import '../core/audio/sound_controller.dart';
import '../core/audio/sound_effect.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_surfaces.dart';
import '../core/theme/app_typography.dart';
import '../shared/buttons/gpa_buttons.dart';
import '../shared/feedback/gpa_progress_indicator.dart';
import '../shared/widgets/technical_background.dart';
import 'kiosk_header.dart';

class KioskShell extends StatefulWidget {
  const KioskShell({
    required this.child,
    this.progressStage,
    this.inactivityTimeout = KioskConfiguration.inactivityTimeout,
    this.inactivityWarningDuration =
        KioskConfiguration.inactivityWarningDuration,
    this.onInactivityWarning,
    this.onSessionExpired,
    this.soundController,
    this.headerHeight = KioskConfiguration.headerHeight,
    this.logoSize = 50,
    this.headerCompanion,
    this.onLogoHeld,
    super.key,
  });

  final Widget child;
  final KioskProgressStage? progressStage;
  final Duration? inactivityTimeout;
  final Duration inactivityWarningDuration;
  final VoidCallback? onInactivityWarning;
  final VoidCallback? onSessionExpired;
  final SoundController? soundController;
  final double headerHeight;
  final double logoSize;
  final Widget? headerCompanion;
  final VoidCallback? onLogoHeld;

  @override
  State<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends State<KioskShell> {
  late final SoundController _soundController;
  Timer? _inactivityTimer;
  Timer? _expirationTimer;
  Timer? _countdownTimer;
  bool _isActive = true;
  bool _showInactivityWarning = false;
  int _warningSeconds = 10;

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
        oldWidget.inactivityWarningDuration !=
            widget.inactivityWarningDuration) {
      _scheduleInactivity();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActive = TickerMode.valuesOf(context).enabled;
    if (_isActive == isActive) return;
    _isActive = isActive;
    if (_isActive) {
      _scheduleInactivity();
    } else {
      _cancelInactivity();
      _showInactivityWarning = false;
    }
  }

  void _registerActivity(PointerDownEvent event) {
    if (_showInactivityWarning) return;
    _scheduleInactivity();
  }

  void _scheduleInactivity() {
    _cancelInactivity();

    if (!_isActive) return;

    final timeout = widget.inactivityTimeout;
    if (timeout == null) return;

    _inactivityTimer = Timer(timeout, _warnAboutInactivity);
  }

  void _cancelInactivity() {
    _inactivityTimer?.cancel();
    _expirationTimer?.cancel();
    _countdownTimer?.cancel();
    _inactivityTimer = null;
    _expirationTimer = null;
    _countdownTimer = null;
  }

  void _warnAboutInactivity() {
    if (!mounted || !_isActive) return;
    final milliseconds = widget.inactivityWarningDuration.inMilliseconds;
    setState(() {
      _showInactivityWarning = true;
      _warningSeconds = (milliseconds / 1000).ceil().clamp(1, 999);
    });
    unawaited(_soundController.play(SoundEffect.warning));
    widget.onInactivityWarning?.call();
    _expirationTimer = Timer(widget.inactivityWarningDuration, _expireSession);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_showInactivityWarning || _warningSeconds <= 1) return;
      setState(() => _warningSeconds--);
    });
  }

  void _expireSession() {
    if (!mounted) return;

    _cancelInactivity();
    setState(() => _showInactivityWarning = false);

    if (widget.onSessionExpired case final callback?) {
      callback();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _continueSession() {
    if (!_showInactivityWarning) return;
    setState(() => _showInactivityWarning = false);
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
                      child: Stack(
                        children: [
                          FocusTraversalGroup(
                            child: Column(
                              children: [
                                KioskHeader(
                                  soundController: _soundController,
                                  progressStage: widget.progressStage,
                                  height: widget.headerHeight,
                                  logoSize: widget.logoSize,
                                  companion: widget.headerCompanion,
                                  onLogoHeld: widget.onLogoHeld,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: KioskConfiguration.horizontalMargin,
                                      right:
                                          KioskConfiguration.horizontalMargin,
                                      bottom: KioskConfiguration.bottomMargin,
                                    ),
                                    child: widget.child,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showInactivityWarning)
                            Positioned.fill(
                              child: _InactivityWarningOverlay(
                                seconds: _warningSeconds,
                                onContinue: _continueSession,
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
    );
  }

  @override
  void dispose() {
    _cancelInactivity();
    super.dispose();
  }
}

class _InactivityWarningOverlay extends StatelessWidget {
  const _InactivityWarningOverlay({
    required this.seconds,
    required this.onContinue,
  });

  final int seconds;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      builder: (context, progress, child) {
        final backdropProgress = (progress * 220 / 180).clamp(0.0, 1.0);
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.carbon.withValues(
                  alpha: 0.34 * backdropProgress,
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.96 + (0.04 * progress),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        key: const ValueKey('inactivity-warning-modal'),
        width: 490,
        padding: const EdgeInsets.all(30),
        decoration: AppSurfaces.card(selected: false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.gpaCrimson.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.gpaCrimson,
                size: 31,
              ),
            ),
            const SizedBox(height: 18),
            Text('¿Sigues ahí?', style: AppTypography.screenTitle),
            const SizedBox(height: 10),
            Text(
              'Cerraremos esta sesión para proteger tu información.',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            Text(
              '$seconds s',
              key: const ValueKey('inactivity-warning-countdown'),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.gpaCrimson,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: GpaPrimaryButton(
                label: 'Continuar',
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
