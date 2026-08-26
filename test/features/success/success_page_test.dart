import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/models/registration_session.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/success/presentation/success_page.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('muestra el nombre y la opción final sin desbordarse', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final engine = FakeSoundPlaybackEngine();
    final soundController = SoundController(engine: engine);
    addTearDown(soundController.dispose);
    await soundController.unlock();
    engine.playCalls.clear();
    var finished = false;
    final submission = RegistrationSession(
      sessionId: 'registro-1',
      startedAt: DateTime(2026, 8, 25, 10),
      personType: VisitorProfile.student,
      name: 'Pablo',
      company: 'GPA',
      email: 'pablo1@correo.com',
      phone: '1111111111',
      wantsInformation: false,
      interestPath: const [
        'Fabricación Avanzada',
        'Servicios Industriales (Corte, Doblez, Pailería, Pintura)',
      ],
      completedAt: DateTime(2026, 8, 25, 10, 2),
      duration: const Duration(minutes: 2),
      kioskId: 'kiosk-1',
      eventId: 'evento-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          inactivityTimeout: null,
          soundController: soundController,
          child: SuccessPage(
            submission: submission,
            onFinish: () => finished = true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Gracias por conectar con GPA'), findsOneWidget);
    expect(
      find.text('Lo que te interesa también nos interesa.'),
      findsOneWidget,
    );
    expect(find.textContaining('Tu registro quedó completo.'), findsOneWidget);
    expect(find.textContaining(submission.finalInterest), findsOneWidget);
    expect(find.text('Finalizar'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('success-reset-countdown')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(const ValueKey('success-reset-countdown')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      0,
    );

    await tester.pump(AppMotion.successSoundDelay);
    expect(engine.playCalls.single.$1, 'audio/ui_success.wav');
    await tester.pump(
      AppMotion.successCountdownDelay - AppMotion.successSoundDelay,
    );
    expect(find.text('Nueva sesión en 5 s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4, milliseconds: 999));
    expect(finished, isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    expect(finished, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa el texto autorizado y permite finalizar de inmediato', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    var finished = false;
    final submission = RegistrationSession(
      sessionId: 'registro-2',
      startedAt: DateTime(2026, 8, 25, 10),
      personType: VisitorProfile.company,
      name: 'Pablo',
      company: 'GPA',
      email: 'pablo1@correo.com',
      phone: '1111111111',
      wantsInformation: true,
      interestPath: const ['Software Industrial', 'Sistemas Web'],
      completedAt: DateTime(2026, 8, 25, 10, 1),
      duration: const Duration(minutes: 1),
      kioskId: 'kiosk-1',
      eventId: 'evento-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          inactivityTimeout: null,
          child: SuccessPage(
            submission: submission,
            onFinish: () => finished = true,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Registramos tus intereses y podremos compartir'),
      findsOneWidget,
    );
    await tester.tap(find.text('Finalizar'));
    await tester.pump();
    expect(finished, isTrue);
  });
}
