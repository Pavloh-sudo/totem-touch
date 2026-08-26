import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../domain/interest_area.dart';
import 'widgets/interest_area_card.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({
    required this.registration,
    required this.onBack,
    required this.onSelectionStarted,
    this.onSelected,
    super.key,
  });

  final VisitorRegistration registration;
  final VoidCallback onBack;
  final ValueChanged<InterestArea> onSelectionStarted;
  final Future<void> Function(InterestArea area)? onSelected;

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  InterestArea? _selectedArea;
  bool _openingNextScreen = false;

  void _selectArea(InterestArea area) {
    if (_openingNextScreen || _selectedArea != null) return;
    final soundController = SoundControllerScope.maybeOf(context);
    if (soundController != null) {
      unawaited(soundController.play(SoundEffect.selection));
    }
    setState(() {
      _selectedArea = area;
      _openingNextScreen = widget.onSelected != null;
    });
    widget.onSelectionStarted(area);
    if (widget.onSelected != null) unawaited(_finishSelection(area));
  }

  Future<void> _finishSelection(InterestArea area) async {
    await Future<void>.delayed(AppMotion.interestUnselected);
    if (!mounted) return;
    await widget.onSelected!(area);
    if (mounted) {
      setState(() {
        _selectedArea = null;
        _openingNextScreen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('¿Qué te gustaría explorar?', style: AppTypography.screenTitle),
        const SizedBox(height: 8),
        Text('Elige el área que más te interesa.', style: AppTypography.body),
        const SizedBox(height: 22),
        for (var row = 0; row < 2; row++) ...[
          SizedBox(
            height: 166,
            child: Row(
              children: [
                for (var column = 0; column < 3; column++) ...[
                  Expanded(
                    child: InterestAreaCard(
                      area: InterestArea.values[(row * 3) + column],
                      entryIndex: (row * 3) + column,
                      selected:
                          _selectedArea ==
                          InterestArea.values[(row * 3) + column],
                      dimmed:
                          _selectedArea != null &&
                          _selectedArea !=
                              InterestArea.values[(row * 3) + column],
                      onPressed: _selectedArea == null
                          ? () => _selectArea(
                              InterestArea.values[(row * 3) + column],
                            )
                          : null,
                    ),
                  ),
                  if (column < 2) const SizedBox(width: 20),
                ],
              ],
            ),
          ),
          if (row == 0) const SizedBox(height: 20),
        ],
        const Spacer(),
        SizedBox(
          width: 170,
          child: GpaSecondaryButton(
            label: 'Volver',
            icon: Icons.arrow_back_rounded,
            sound: SoundEffect.back,
            onPressed: _openingNextScreen ? null : widget.onBack,
          ),
        ),
      ],
    );
  }
}
