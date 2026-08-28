import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/export/gpa_excel_exporter.dart';
import 'package:totem_touch/data/local/memory_interest_submission_repository.dart';
import 'package:totem_touch/data/models/registration_session.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/admin/presentation/admin_screen.dart';

void main() {
  testWidgets('exige dos confirmaciones antes de borrar registros locales', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);

    final repository = MemoryInterestSubmissionRepository();
    await repository.save(_session());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          inactivityTimeout: null,
          child: AdminScreen(
            repository: repository,
            exporter: const GpaExcelExporter(),
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Estado de guardado'), findsOneWidget);
    expect(find.text('En este tótem'), findsOneWidget);
    expect(find.text('Servidor'), findsOneWidget);
    expect(find.textContaining('se conectará después'), findsNothing);
    expect(find.text('Reiniciar registros de prueba'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Reiniciar registros de prueba'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('¿Estás seguro?'), findsOneWidget);
    expect(repository.submissions, hasLength(1));

    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('¿De verdad estás seguro?'), findsOneWidget);
    expect(repository.submissions, hasLength(1));

    await tester.tap(find.text('Sí, borrar registros'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(repository.submissions, isEmpty);
    expect(find.text('¿De verdad estás seguro?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

RegistrationSession _session() {
  return RegistrationSession(
    sessionId: 'GPA-20260828-PRUEBA',
    startedAt: DateTime(2026, 8, 28, 10),
    personType: VisitorProfile.professional,
    name: 'Registro de prueba',
    company: 'GPA',
    email: 'prueba1@correo.com',
    phone: '6141234567',
    wantsInformation: true,
    interestPath: const [
      'Robótica & Automatización',
      'Automatización con Robots',
    ],
    completedAt: DateTime(2026, 8, 28, 10, 2),
    duration: const Duration(minutes: 2),
    kioskId: 'totem-prueba',
    eventId: 'evento-prueba',
  );
}
