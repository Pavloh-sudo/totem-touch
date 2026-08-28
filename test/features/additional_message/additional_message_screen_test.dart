import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/core/animations/app_motion.dart';
import 'package:kiosco_gpa/core/audio/sound_controller.dart';
import 'package:kiosco_gpa/core/session/registration_session_controller.dart';
import 'package:kiosco_gpa/core/theme/app_theme.dart';
import 'package:kiosco_gpa/data/local/memory_interest_submission_repository.dart';
import 'package:kiosco_gpa/data/models/registration_session.dart';
import 'package:kiosco_gpa/data/models/visitor_registration.dart';
import 'package:kiosco_gpa/features/additional_message/presentation/additional_message_screen.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  late RegistrationSessionController sessionController;

  Future<void> pumpScreen(
    WidgetTester tester, {
    required MemoryInterestSubmissionRepository repository,
    required Future<void> Function(RegistrationSession session) onCompleted,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    final sound = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(sound.dispose);
    sessionController = RegistrationSessionController(
      idGenerator: () => 'registro-mensaje',
    );
    addTearDown(sessionController.dispose);
    sessionController.begin();
    sessionController.setRegistration(
      const VisitorRegistration(
        profile: VisitorProfile.professional,
        name: 'Pablo',
        organization: 'GPA',
        email: 'pablo1@correo.com',
        phone: '1111111111',
        acceptsInformation: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: AdditionalMessageScreen(
          interestPaths: const [
            ['Software Industrial', 'Sistemas Web'],
          ],
          sessionController: sessionController,
          repository: repository,
          onBack: () {},
          onCompleted: onCompleted,
          onSessionExpired: () {},
        ),
      ),
    );
  }

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('guarda el comentario opcional antes de terminar', (
    tester,
  ) async {
    final repository = MemoryInterestSubmissionRepository();
    RegistrationSession? completed;
    await pumpScreen(
      tester,
      repository: repository,
      onCompleted: (session) async => completed = session,
    );

    expect(find.text('¿Quieres compartirnos algo más?'), findsOneWidget);
    expect(repository.submissions, isEmpty);
    await tester.tap(find.byKey(const ValueKey('additional-message-field')));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    for (final key in ['H', 'O', 'L', 'A']) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }

    await tester.tap(find.text('Finalizar'));
    await tester.pump(AppMotion.keyboardHide + AppMotion.interestSaving);

    expect(completed, isNotNull);
    expect(completed!.additionalMessage, 'Hola');
    expect(repository.submissions, hasLength(1));
    expect(repository.submissions.single.additionalMessage, 'Hola');
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite omitir el mensaje', (tester) async {
    final repository = MemoryInterestSubmissionRepository();
    RegistrationSession? completed;
    await pumpScreen(
      tester,
      repository: repository,
      onCompleted: (session) async => completed = session,
    );

    await tester.tap(find.text('Omitir'));
    await tester.pump(AppMotion.interestSaving);

    expect(completed?.additionalMessage, isEmpty);
    expect(repository.submissions, hasLength(1));
  });
}
