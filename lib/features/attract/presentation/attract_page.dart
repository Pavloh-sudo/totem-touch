import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/cards/gpa_surface_card.dart';
import '../../../shared/mascot/gp_mascot.dart';

class AttractPage extends StatefulWidget {
  const AttractPage({this.onStart, super.key});

  final VoidCallback? onStart;

  @override
  State<AttractPage> createState() => _AttractPageState();
}

class _AttractPageState extends State<AttractPage> {
  GpMascotState _mascotState = GpMascotState.idle;
  Timer? _mascotResetTimer;

  void _start() {
    _mascotResetTimer?.cancel();
    setState(() => _mascotState = GpMascotState.wave);
    _mascotResetTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _mascotState = GpMascotState.idle);
    });
    widget.onStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.gpaCrimson,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Descubre todo lo que hacemos en GPA',
                style: textTheme.displayLarge,
              ),
              const SizedBox(height: 22),
              Text(
                'Conoce nuestras áreas, proyectos y oportunidades.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 38),
              SizedBox(
                width: 300,
                child: GpaPrimaryButton(
                  label: 'Quiero conocer más',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _start,
                  unlockSound: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 9,
          child: SizedBox(
            height: 520,
            child: GpaSurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: GpMascot(
                  state: _mascotState,
                  size: 390,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mascotResetTimer?.cancel();
    super.dispose();
  }
}
