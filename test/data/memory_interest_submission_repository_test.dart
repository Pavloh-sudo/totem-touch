import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/data/local/memory_interest_submission_repository.dart';
import 'package:totem_touch/data/models/interest_submission.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';

void main() {
  test('el mismo registro no se guarda dos veces', () async {
    final repository = MemoryInterestSubmissionRepository();
    final submission = InterestSubmission(
      id: 'registro-1',
      registration: const VisitorRegistration(
        profile: VisitorProfile.other,
        name: 'Prueba',
        organization: '',
        email: 'prueba1@correo.com',
        phone: '1111111111',
        acceptsInformation: false,
      ),
      pathIds: const ['area', 'opcion'],
      pathTitles: const ['Área', 'Opción'],
      createdAt: DateTime(2026, 8, 25),
    );

    await repository.save(submission);
    await repository.save(submission);

    expect(repository.submissions, [submission]);
  });
}
