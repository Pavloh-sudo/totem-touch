part of '../gp_mascot.dart';

class _GpMascotState extends State<GpMascot> with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _entranceController;
  late final AnimationController _reactionController;
  late final AnimationController _headController;
  late final CurvedAnimation _entranceAnimation;
  late final Listenable _motionListenable;
  late final _GpMascotRandom _random;

  late Widget _artwork;
  late _GpMascotCapabilities _capabilities;
  Animation<double> _headAngle = const AlwaysStoppedAnimation(0);

  Timer? _blinkScheduleTimer;
  Timer? _blinkPhaseTimer;
  Timer? _blinkFinishTimer;
  Timer? _doubleBlinkTimer;
  Timer? _headScheduleTimer;

  bool _eyesClosed = false;
  bool _tickersEnabled = true;
  bool _reduceMotion = false;
  bool _entranceHandled = false;
  bool _reactionInitialized = false;

  @override
  void initState() {
    super.initState();
    _random = _GpMascotRandom();
    _artwork = _resolveArtwork();
    _capabilities = _GpMascotCapabilities.fromArtwork(_artwork);

    _breathingController = AnimationController(
      vsync: this,
      duration: _GpMascotTiming.breathing,
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: _GpMascotTiming.entrance,
    );
    _reactionController = AnimationController(vsync: this);
    _headController = AnimationController(vsync: this);
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _motionListenable = Listenable.merge([
      _breathingController,
      _entranceController,
      _reactionController,
      _headController,
    ]);

    _reactionController.addStatusListener(_onReactionStatusChanged);
    _headController.addStatusListener(_onHeadStatusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.maybeOf(context);
    _tickersEnabled = TickerMode.valuesOf(context).enabled;
    _reduceMotion = mediaQuery?.disableAnimations ?? false;

    if (!_entranceHandled &&
        (!widget.playEntranceAnimation || _tickersEnabled)) {
      _entranceHandled = true;
      if (widget.playEntranceAnimation && !_reduceMotion) {
        _entranceController.forward(from: 0);
      } else {
        _entranceController.value = 1;
      }
    }

    if (!_reactionInitialized) {
      _reactionInitialized = true;
      _playReaction();
    }
    _synchronizeActivity();
  }

  @override
  void didUpdateWidget(covariant GpMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.artwork != widget.artwork ||
        oldWidget.mascotContext != widget.mascotContext) {
      _artwork = _resolveArtwork();
      _capabilities = _GpMascotCapabilities.fromArtwork(_artwork);
      _cancelBlinkTimers();
      _cancelHeadMotion();
    }
    if (oldWidget.state != widget.state) {
      _playReaction();
      _synchronizeBlink();
    }
    if (oldWidget.enableIdleMotion != widget.enableIdleMotion ||
        oldWidget.artwork != widget.artwork ||
        oldWidget.mascotContext != widget.mascotContext) {
      _synchronizeActivity();
    }
  }

  Widget _resolveArtwork() {
    return widget.artwork ?? _GpAssetRig.artworkFor(widget.mascotContext);
  }

  void _synchronizeActivity() {
    if (!_tickersEnabled) {
      _breathingController.stop();
      _reactionController.stop();
      _headController.stop();
      _cancelBlinkTimers();
      _cancelHeadMotion();
      return;
    }

    if (_reduceMotion) {
      _breathingController
        ..stop()
        ..value = 0;
      _headController
        ..stop()
        ..value = 0;
      _entranceController.value = 1;
      _settleReactionWithoutMotion();
      _cancelHeadMotion();
    } else if (widget.enableIdleMotion) {
      if (widget.state != GpMascotState.idle &&
          !_reactionController.isAnimating &&
          !_reactionController.isCompleted) {
        _reactionController.forward();
      }
      if (!_breathingController.isAnimating) {
        _breathingController.repeat();
      }
      _synchronizeHeadMotion();
    } else {
      _breathingController
        ..stop()
        ..value = 0;
      _cancelHeadMotion();
    }

    _synchronizeBlink();
  }

  void _playReaction() {
    _cancelHeadMotion();
    _reactionController.stop();

    if (widget.state == GpMascotState.idle) {
      _reactionController.value = 0;
      _synchronizeHeadMotion();
      return;
    }

    if (!_tickersEnabled || _reduceMotion) {
      _settleReactionWithoutMotion();
      return;
    }

    _reactionController
      ..duration = _GpMascotTiming.reaction(widget.state)
      ..forward(from: 0);
  }

  void _settleReactionWithoutMotion() {
    _reactionController
      ..stop()
      ..value = widget.state == GpMascotState.idle ? 0 : 1;
  }

  void _onReactionStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.state.isOneShot) {
      _synchronizeHeadMotion();
    }
  }

  bool get _isVisuallyIdle {
    return widget.state == GpMascotState.idle ||
        (widget.state.isOneShot && _reactionController.isCompleted);
  }

  void _synchronizeBlink() {
    if (!_canBlink) {
      _cancelBlinkTimers();
      return;
    }
    if (_blinkScheduleTimer == null &&
        _blinkPhaseTimer == null &&
        _doubleBlinkTimer == null) {
      _scheduleNextBlink();
    }
  }

  bool get _canBlink {
    return _tickersEnabled &&
        _capabilities.supportsBlink &&
        widget.state != GpMascotState.error;
  }

  void _scheduleNextBlink() {
    if (!_canBlink) return;
    _blinkScheduleTimer?.cancel();
    _blinkScheduleTimer = Timer(_random.nextBlinkInterval, () {
      _blinkScheduleTimer = null;
      _performBlink(allowDouble: true);
    });
  }

  void _performBlink({required bool allowDouble}) {
    if (!_canBlink || !mounted) return;
    final duration = _random.nextBlinkDuration;
    final shouldDouble = allowDouble && _random.shouldDoubleBlink;

    _setEyesClosed(true);
    _blinkPhaseTimer = Timer(
      Duration(microseconds: duration.inMicroseconds ~/ 2),
      () {
        _blinkPhaseTimer = null;
        _setEyesClosed(false);
      },
    );
    _blinkFinishTimer = Timer(duration, () {
      _blinkFinishTimer = null;
      if (!_canBlink) return;
      if (shouldDouble) {
        _doubleBlinkTimer = Timer(_random.doubleBlinkSeparation, () {
          _doubleBlinkTimer = null;
          _performBlink(allowDouble: false);
        });
      } else {
        _scheduleNextBlink();
      }
    });
  }

  void _setEyesClosed(bool value) {
    if (!mounted || _eyesClosed == value) return;
    setState(() => _eyesClosed = value);
  }

  void _cancelBlinkTimers() {
    _blinkScheduleTimer?.cancel();
    _blinkPhaseTimer?.cancel();
    _blinkFinishTimer?.cancel();
    _doubleBlinkTimer?.cancel();
    _blinkScheduleTimer = null;
    _blinkPhaseTimer = null;
    _blinkFinishTimer = null;
    _doubleBlinkTimer = null;
    _eyesClosed = false;
  }

  void _synchronizeHeadMotion() {
    if (!_canMoveHead) {
      _cancelHeadMotion();
      return;
    }
    if (_headScheduleTimer == null && !_headController.isAnimating) {
      _scheduleNextHeadMotion();
    }
  }

  bool get _canMoveHead {
    return _tickersEnabled &&
        !_reduceMotion &&
        widget.enableIdleMotion &&
        _capabilities.supportsHeadMotion &&
        _isVisuallyIdle;
  }

  void _scheduleNextHeadMotion() {
    if (!_canMoveHead) return;
    _headScheduleTimer?.cancel();
    _headScheduleTimer = Timer(_random.nextHeadInterval, () {
      _headScheduleTimer = null;
      _startHeadMotion();
    });
  }

  void _startHeadMotion() {
    if (!_canMoveHead) return;
    final angle = _random.nextHeadAngleDegrees * math.pi / 180;
    _headController.duration = _random.nextHeadDuration;
    _headAngle =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: angle), weight: 50),
          TweenSequenceItem(tween: Tween(begin: angle, end: 0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _headController, curve: Curves.easeInOut),
        );
    _headController.forward(from: 0);
  }

  void _onHeadStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _scheduleNextHeadMotion();
    }
  }

  void _cancelHeadMotion() {
    _headScheduleTimer?.cancel();
    _headScheduleTimer = null;
    _headController
      ..stop()
      ..value = 0;
    _headAngle = const AlwaysStoppedAnimation(0);
  }

  double get _breathingStrength {
    if (!widget.enableIdleMotion || _reduceMotion) return 0;
    if (_isVisuallyIdle) return 1;
    return switch (widget.state) {
      GpMascotState.thinking => 0.45,
      GpMascotState.guide => 0.55,
      GpMascotState.wave || GpMascotState.celebrate => 0.2,
      GpMascotState.error => 0,
      GpMascotState.idle => 1,
    };
  }

  double get _pixelScale {
    return (widget.size / 240).clamp(0.35, 1.5).toDouble();
  }

  Widget _buildArtwork(double breathingPulse) {
    final artwork = _artwork;
    if (artwork case _GpArtworkLayers layers) {
      return layers.animated(
        state: widget.state,
        reactionProgress: _reactionController.value,
        reduceMotion: _reduceMotion,
        eyesClosed: _eyesClosed,
        headAngleRadians: _headAngle.value,
        shadowScale: 1 - (0.03 * breathingPulse),
        shadowOpacity: 1 - (0.04 * breathingPulse),
      );
    }
    return artwork;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: widget.state.semanticsLabel,
      child: SizedBox(
        key: const ValueKey('gp-mascot-frame'),
        width: widget.size,
        height: widget.size,
        child: AnimatedContainer(
          duration: _GpMascotTiming.contextChange,
          curve: Curves.easeOutCubic,
          alignment: widget.alignment,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.mascotContext.accentColor.withValues(alpha: 0.08),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _motionListenable,
              builder: (context, child) {
                final breathingProgress = Curves.easeInOut.transform(
                  _breathingController.value,
                );
                final breathingPulse =
                    math.sin(breathingProgress * math.pi) * _breathingStrength;
                final entrance = _entranceAnimation.value;
                final pose = _poseForState(
                  widget.state,
                  _reactionController.value,
                  _pixelScale,
                  _reduceMotion,
                  _capabilities.supportsArticulation,
                );

                final scale =
                    (0.94 + (0.06 * entrance)) *
                    (1 + (0.012 * breathingPulse)) *
                    pose.scale;
                final translateY =
                    (-2 * _pixelScale * breathingPulse) + pose.translateY;
                final angle = pose.rotationDegrees * math.pi / 180;

                return Opacity(
                  key: const ValueKey('gp-entrance-opacity'),
                  opacity: entrance,
                  child: Transform.translate(
                    offset: Offset(pose.translateX, translateY),
                    child: Transform.rotate(
                      angle: angle,
                      alignment: widget.alignment,
                      child: Transform.scale(
                        scale: scale,
                        alignment: widget.alignment,
                        child: AnimatedSwitcher(
                          duration: _GpMascotTiming.contextChange,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: KeyedSubtree(
                            key: ValueKey(
                              'gp-context-${widget.mascotContext.name}',
                            ),
                            child: _buildArtwork(breathingPulse),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancelBlinkTimers();
    _cancelHeadMotion();
    _reactionController.removeStatusListener(_onReactionStatusChanged);
    _headController.removeStatusListener(_onHeadStatusChanged);
    _entranceAnimation.dispose();
    _breathingController.dispose();
    _entranceController.dispose();
    _reactionController.dispose();
    _headController.dispose();
    super.dispose();
  }
}
