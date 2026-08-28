import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/core/audio/sound_controller.dart';
import 'package:kiosco_gpa/shared/inputs/gpa_consent_checkbox.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('inicia apagado y reproduce selección al 20 por ciento', (
    tester,
  ) async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);
    await controller.unlock();
    engine.playCalls.clear();
    var value = false;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: SoundControllerScope(
          controller: controller,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: GpaConsentCheckbox(
                  value: value,
                  onChanged: (next) => update(() => value = next),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(value, isFalse);
    await tester.tap(find.byType(GpaConsentCheckbox));
    await tester.pump();
    expect(value, isTrue);
    expect(engine.playCalls.single.$1, 'audio/ui_select.wav');
    expect(engine.playCalls.single.$2, closeTo(0.20, 0.0001));

    await tester.pump(const Duration(milliseconds: 120));
    final scale = tester.widget<ScaleTransition>(
      find
          .descendant(
            of: find.byType(GpaConsentCheckbox),
            matching: find.byType(ScaleTransition),
          )
          .first,
    );
    expect(scale.scale.value, greaterThan(1));
    await tester.pump(const Duration(milliseconds: 70));
    expect(scale.scale.value, 1);
  });
}
