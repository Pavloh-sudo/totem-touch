import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/core/audio/sound_controller.dart';
import 'package:kiosco_gpa/shared/inputs/gpa_touch_field.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('muestra foco, validación y error en español', (tester) async {
    final engine = FakeSoundPlaybackEngine();
    final soundController = SoundController(engine: engine);
    final textController = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(soundController.dispose);
    addTearDown(textController.dispose);
    addTearDown(focusNode.dispose);
    await soundController.unlock();
    engine.playCalls.clear();
    var errorText = <String?>[null];
    var valid = false;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: SoundControllerScope(
          controller: soundController,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: GpaTouchField(
                  controller: textController,
                  focusNode: focusNode,
                  label: 'Correo electrónico',
                  errorText: errorText.single,
                  isValid: valid,
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Correo electrónico'));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    update(() {
      textController.text = 'correo@ejemplo.com';
      valid = true;
    });
    focusNode.unfocus();
    await tester.pump();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    update(() {
      valid = false;
      errorText = ['Revisa el correo antes de continuar.'];
    });
    await tester.pump();
    expect(find.text('Revisa el correo antes de continuar.'), findsOneWidget);
    expect(engine.playCalls.single.$1, 'audio/ui_error.wav');
  });
}
