import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/mascot/gp_mascot.dart';

class AttractPage extends StatefulWidget {
  const AttractPage({required this.onStart, super.key});

  final Future<void> Function() onStart;

  @override
  State<AttractPage> createState() => _AttractPageState();
}

class _AttractPageState extends State<AttractPage> {
  static const _welcomeWaveDuration = Duration(milliseconds: 920);
  static const _ambientReactionDuration = Duration(milliseconds: 900);
  static const _ambientReactionInterval = Duration(seconds: 15);

  GpMascotState _mascotState = GpMascotState.idle;
  Timer? _welcomeTimer;
  Timer? _reactionResetTimer;
  Timer? _ambientReactionTimer;
  bool _nextAmbientReactionIsWave = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _welcomeTimer = Timer(AppMotion.emphasis, _playWelcomeWave);
  }

  void _playWelcomeWave() {
    if (!mounted || _started) return;
    _setMascotState(GpMascotState.wave);
    _reactionResetTimer = Timer(_welcomeWaveDuration, () {
      if (!mounted || _started) return;
      _setMascotState(GpMascotState.idle);
      _scheduleAmbientReaction();
    });
  }

  void _scheduleAmbientReaction() {
    _ambientReactionTimer?.cancel();
    _ambientReactionTimer = Timer(_ambientReactionInterval, () {
      if (!mounted || _started) return;
      _setMascotState(
        _nextAmbientReactionIsWave ? GpMascotState.wave : GpMascotState.guide,
      );
      _nextAmbientReactionIsWave = !_nextAmbientReactionIsWave;
      _reactionResetTimer = Timer(_ambientReactionDuration, () {
        if (!mounted || _started) return;
        _setMascotState(GpMascotState.idle);
        _scheduleAmbientReaction();
      });
    });
  }

  void _setMascotState(GpMascotState state) {
    if (mounted && _mascotState != state) {
      setState(() => _mascotState = state);
    }
  }

  void _start() {
    if (_started) return;
    _started = true;
    _cancelGreetingTimers();
    _setMascotState(GpMascotState.wave);
    unawaited(_openRegistration());
  }

  Future<void> _openRegistration() async {
    await widget.onStart();
    if (!mounted) return;
    _started = false;
    _setMascotState(GpMascotState.idle);
    _welcomeTimer = Timer(AppMotion.emphasis, _playWelcomeWave);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gpaCrimson,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu siguiente idea puede empezar aquí.',
                    style: textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Conoce nuestras soluciones, oportunidades y áreas de '
                    'especialización. Cuéntanos qué te interesa y conectemos '
                    'contigo.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: 280,
                    child: GpaPrimaryButton(
                      label: 'Quiero conocer más',
                      icon: Icons.arrow_forward_rounded,
                      trailingIcon: true,
                      height: 68,
                      sound: SoundEffect.selection,
                      onPressed: _started ? null : _start,
                      unlockSound: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 52),
        SizedBox(
          width: 310,
          child: Center(
            child: GpMascot(
              state: _mascotState,
              size: 310,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  void _cancelGreetingTimers() {
    _welcomeTimer?.cancel();
    _reactionResetTimer?.cancel();
    _ambientReactionTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelGreetingTimers();
    super.dispose();
  }
}
