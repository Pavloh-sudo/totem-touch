import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/data/local/memory_interest_submission_repository.dart';
import 'package:kiosco_gpa/data/models/registration_session.dart';
import 'package:kiosco_gpa/data/models/visitor_registration.dart';

void main() {
  test('el mismo registro no se guarda dos veces', () async {
    final repository = MemoryInterestSubmissionRepository();
    final submission = RegistrationSession(
      sessionId: 'registro-1',
      startedAt: DateTime(2026, 8, 25, 10),
      personType: VisitorProfile.other,
      name: 'Prueba',
      company: '',
      email: 'prueba1@correo.com',
      phone: '1111111111',
      wantsInformation: false,
      interestPath: const ['Área', 'Opción'],
      completedAt: DateTime(2026, 8, 25, 10, 2),
      duration: const Duration(minutes: 2),
      kioskId: 'kiosk-1',
      eventId: 'evento-1',
    );

    await repository.save(submission);
    await repository.save(submission);

    expect(repository.submissions, [submission]);

    await repository.clearAll();

    expect(repository.submissions, isEmpty);
    expect((await repository.getSummary()).total, 0);
  });
}
