import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/shared/keyboard/gpa_virtual_keyboard.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('aparece en 220 ms y se oculta en 180 ms', (tester) async {
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);
    var visible = false;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: SoundControllerScope(
          controller: controller,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: GpaVirtualKeyboard(
                    visible: visible,
                    layout: GpaKeyboardLayout.text,
                    onText: (_) {},
                    onBackspace: () {},
                    onDone: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    double height() => tester
        .getSize(find.byKey(const ValueKey('gpa-virtual-keyboard-space')))
        .height;

    expect(height(), 0);
    update(() => visible = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));
    expect(height(), inExclusiveRange(0, 268));
    await tester.pump(const Duration(milliseconds: 110));
    expect(height(), 268);

    update(() => visible = false);
    await tester.pump();
    await tester.pump(AppMotion.keyboardHide - const Duration(milliseconds: 1));
    expect(height(), greaterThan(0));
    await tester.pump(const Duration(milliseconds: 1));
    expect(height(), 0);
  });

  testWidgets('correo tiene números, shortcuts y volumen bajo', (tester) async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);
    await controller.unlock();
    engine.playCalls.clear();
    var value = '';

    await tester.pumpWidget(
      MaterialApp(
        home: SoundControllerScope(
          controller: controller,
          child: Scaffold(
            body: GpaVirtualKeyboard(
              visible: true,
              layout: GpaKeyboardLayout.email,
              onText: (text) => value += text,
              onBackspace: () {},
              onDone: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('@'), findsOneWidget);
    expect(find.text('.'), findsOneWidget);
    expect(find.text('_'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    for (final domain in [
      '@gmail.com',
      '@hotmail.com',
      '@outlook.com',
      '@yahoo.com',
      '@icloud.com',
    ]) {
      expect(find.text(domain), findsOneWidget);
    }
    expect(find.text('@live.com'), findsNothing);

    await tester.tap(find.text('123'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('@gmail.com'), findsOneWidget);
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(value, '1');

    await tester.tap(find.text('@gmail.com'));
    await tester.pump();
    expect(value, '1@gmail.com');
    expect(engine.playCalls.last.$1, 'audio/ui_tap.wav');
    expect(engine.playCalls.last.$2, closeTo(0.135, 0.0001));
  });

  testWidgets('backspace repite después de mantenerlo 450 ms', (tester) async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);
    await controller.unlock();
    engine.playCalls.clear();
    var deletions = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SoundControllerScope(
          controller: controller,
          child: Scaffold(
            body: GpaVirtualKeyboard(
              visible: true,
              layout: GpaKeyboardLayout.numeric,
              onText: (_) {},
              onBackspace: () => deletions++,
              onDone: () {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.backspace_outlined)),
    );
    await tester.pump(
      AppMotion.keyboardBackspaceHold - const Duration(milliseconds: 1),
    );
    expect(deletions, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(deletions, 1);
    await tester.pump(AppMotion.keyboardBackspaceRepeat * 2);
    expect(deletions, 3);
    await gesture.up();
    await tester.pump();
    expect(deletions, 3);
  });
}
