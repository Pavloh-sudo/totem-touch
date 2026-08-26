import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/models/interest_submission.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/success/presentation/success_page.dart';

void main() {
  testWidgets('muestra el nombre y la opción final sin desbordarse', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final submission = InterestSubmission(
      id: 'registro-1',
      registration: const VisitorRegistration(
        profile: VisitorProfile.student,
        name: 'Pablo',
        organization: 'GPA',
        email: 'pablo1@correo.com',
        phone: '1111111111',
        acceptsInformation: false,
      ),
      pathIds: const ['fabricacion', 'servicios'],
      pathTitles: const [
        'Fabricación Avanzada',
        'Servicios Industriales (Corte, Doblez, Pailería, Pintura)',
      ],
      createdAt: DateTime(2026, 8, 25),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          inactivityTimeout: null,
          child: SuccessPage(submission: submission, onFinish: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('¡Gracias, Pablo!'), findsOneWidget);
    expect(find.text(submission.finalInterest), findsOneWidget);
    expect(find.text('Finalizar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
