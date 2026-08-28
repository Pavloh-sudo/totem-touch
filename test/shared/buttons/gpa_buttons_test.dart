import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/core/animations/app_motion.dart';
import 'package:kiosco_gpa/core/audio/sound_controller.dart';
import 'package:kiosco_gpa/shared/buttons/gpa_buttons.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  Widget testApp(Widget child, SoundController controller) {
    return MaterialApp(
      home: SoundControllerScope(
        controller: controller,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('el primer CTA desbloquea el sonido', (tester) async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testApp(
        GpaPrimaryButton(
          label: 'Quiero conocer más',
          unlockSound: true,
          onPressed: () {},
        ),
        controller,
      ),
    );
    await tester.tap(find.text('Quiero conocer más'));
    await tester.pump();

    expect(controller.isUnlocked, isTrue);
    expect(engine.playCalls.single.$1, 'audio/ui_tap.wav');
  });

  testWidgets('responde al touch down y touch up sin cambiar de tamaño', (
    tester,
  ) async {
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testApp(
        GpaPrimaryButton(label: 'Continuar', onPressed: () {}),
        controller,
      ),
    );
    final initialSize = tester.getSize(find.byType(GpaPrimaryButton));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GpaPrimaryButton)),
    );
    await tester.pump(AppMotion.touchDown);

    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.975,
    );
    expect(tester.getSize(find.byType(GpaPrimaryButton)), initialSize);

    await gesture.up();
    await tester.pump(AppMotion.touchUp);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(tester.getSize(find.byType(GpaPrimaryButton)), initialSize);
  });

  testWidgets('muestra loading, disabled y success con el mismo sistema', (
    tester,
  ) async {
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);
    var presses = 0;

    await tester.pumpWidget(
      testApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GpaPrimaryButton(
              label: 'Guardando',
              state: GpaButtonState.loading,
              onPressed: () => presses++,
            ),
            GpaSecondaryButton(
              label: 'Desactivado',
              state: GpaButtonState.disabled,
              onPressed: () => presses++,
            ),
            GpaIconButton(
              icon: Icons.close,
              semanticLabel: 'Correcto',
              state: GpaButtonState.success,
              onPressed: () => presses++,
            ),
          ],
        ),
        controller,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('Desactivado'), warnIfMissed: false);
    expect(presses, 0);
  });
}
