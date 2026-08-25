import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_header.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/configuration/kiosk_configuration.dart';
import 'package:totem_touch/shared/feedback/gpa_progress_indicator.dart';

import '../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('mantiene header, márgenes y progreso dentro de 1024 x 768', (
    tester,
  ) async {
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: KioskShell(
          soundController: controller,
          inactivityTimeout: null,
          progressStage: KioskProgressStage.detail,
          child: const Text('Contenido'),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byType(KioskHeader)).height,
      KioskConfiguration.headerHeight,
    );
    expect(find.text('Datos'), findsOneWidget);
    expect(find.text('Interés'), findsOneWidget);
    expect(find.text('Detalle'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('technical-background')), findsOneWidget);
  });

  testWidgets('avisa y termina una sesión inactiva', (tester) async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);
    await controller.unlock();
    engine.playCalls.clear();
    engine.stopCalls = 0;
    var warnings = 0;
    var expirations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: KioskShell(
          soundController: controller,
          inactivityTimeout: const Duration(milliseconds: 100),
          warningBeforeTimeout: const Duration(milliseconds: 30),
          onInactivityWarning: () => warnings++,
          onSessionExpired: () => expirations++,
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 75));

    expect(warnings, 1);
    expect(engine.playCalls.single.$1, 'audio/ui_warning.wav');

    await tester.pump(const Duration(milliseconds: 30));
    expect(expirations, 1);
  });
}
