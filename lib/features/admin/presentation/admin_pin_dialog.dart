import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/buttons/gpa_buttons.dart';

class AdminPinDialog extends StatefulWidget {
  const AdminPinDialog({required this.expectedPin, super.key});

  final String expectedPin;

  @override
  State<AdminPinDialog> createState() => _AdminPinDialogState();
}

class _AdminPinDialogState extends State<AdminPinDialog> {
  String _digits = '';
  String? _error;

  void _addDigit(String digit) {
    if (_digits.length >= widget.expectedPin.length) return;
    setState(() {
      _digits += digit;
      _error = null;
    });
    if (_digits.length == widget.expectedPin.length) {
      _verify();
    }
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    setState(() {
      _digits = _digits.substring(0, _digits.length - 1);
      _error = null;
    });
  }

  void _verify() {
    if (_digits == widget.expectedPin) {
      Navigator.of(context).pop(true);
      return;
    }
    final sound = SoundControllerScope.maybeOf(context);
    if (sound != null) unawaited(sound.play(SoundEffect.error));
    setState(() {
      _digits = '';
      _error = 'PIN incorrecto';
    });
  }

  @override
  Widget build(BuildContext context) {
    final keys = <String?>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      null,
      '0',
      'backspace',
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(28),
      child: Container(
        key: const ValueKey('admin-pin-dialog'),
        width: 430,
        padding: const EdgeInsets.all(28),
        decoration: AppSurfaces.card(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Acceso administrativo',
                    style: AppTypography.screenTitle.copyWith(fontSize: 28),
                  ),
                ),
                GpaIconButton(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa el PIN para continuar.',
              style: AppTypography.body.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.expectedPin.length, (index) {
                final filled = index < _digits.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: filled ? AppColors.gpaCrimson : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: filled ? AppColors.gpaCrimson : AppColors.steel,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(
              height: 34,
              child: Center(
                child: Text(
                  _error ?? '',
                  key: const ValueKey('admin-pin-error'),
                  style: AppTypography.auxiliary.copyWith(
                    color: AppColors.gpaCrimson,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.75,
                ),
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final key = keys[index];
                  if (key == null) return const SizedBox.shrink();
                  if (key == 'backspace') {
                    return GpaSecondaryButton(
                      label: 'Borrar',
                      icon: Icons.backspace_outlined,
                      onPressed: _removeDigit,
                      height: 58,
                    );
                  }
                  return GpaSecondaryButton(
                    label: key,
                    onPressed: () => _addDigit(key),
                    height: 58,
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
