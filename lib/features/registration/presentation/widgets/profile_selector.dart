import 'package:flutter/material.dart';

import '../../../../core/audio/sound_effect.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/visitor_registration.dart';
import '../../../../shared/buttons/gpa_buttons.dart';

class ProfileSelector extends StatelessWidget {
  const ProfileSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final VisitorProfile? selected;
  final ValueChanged<VisitorProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Soy', style: AppTypography.label),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                for (
                  var index = 0;
                  index < VisitorProfile.values.length;
                  index++
                ) ...[
                  Expanded(
                    child: selected == VisitorProfile.values[index]
                        ? GpaPrimaryButton(
                            label: VisitorProfile.values[index].label,
                            height: 56,
                            sound: SoundEffect.selection,
                            onPressed: () =>
                                onSelected(VisitorProfile.values[index]),
                          )
                        : GpaSecondaryButton(
                            label: VisitorProfile.values[index].label,
                            height: 56,
                            sound: SoundEffect.selection,
                            onPressed: () =>
                                onSelected(VisitorProfile.values[index]),
                          ),
                  ),
                  if (index < VisitorProfile.values.length - 1)
                    const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
