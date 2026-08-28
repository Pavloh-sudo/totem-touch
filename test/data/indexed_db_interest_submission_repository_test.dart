import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:kiosco_gpa/data/local/indexed_db_interest_submission_repository.dart';
import 'package:kiosco_gpa/data/models/registration_session.dart';
import 'package:kiosco_gpa/data/models/visitor_registration.dart';

void main() {
  test(
    'conserva registros al crear otra instancia y evita duplicados',
    () async {
      final databaseName =
          'gpa-test-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
      final firstRepository = IndexedDbInterestSubmissionRepository(
        factory: idbFactoryMemory,
        databaseName: databaseName,
      );
      final submission = RegistrationSession(
        sessionId: 'GPA-20260826-550E8400-E29B-41D4-A716-446655440000',
        startedAt: DateTime(2026, 8, 26, 10),
        personType: VisitorProfile.company,
        name: 'Pablo',
        company: 'GPA',
        email: 'pablo1@correo.com',
        phone: '1111111111',
        wantsInformation: true,
        interestPath: const [
          'Robótica & Automatización',
          'Automatización con Robots',
        ],
        additionalInterestPaths: const [
          ['Software Industrial', 'Sistemas Web'],
        ],
        additionalMessage: 'Busco una integración para la planta.',
        completedAt: DateTime(2026, 8, 26, 10, 2),
        duration: const Duration(minutes: 2),
        kioskId: 'kiosco-prueba',
        eventId: 'evento-prueba',
      );

      await firstRepository.save(submission);
      await firstRepository.save(submission);

      final secondRepository = IndexedDbInterestSubmissionRepository(
        factory: idbFactoryMemory,
        databaseName: databaseName,
      );
      final records = await secondRepository.getAll();
      final summary = await secondRepository.getSummary();

      expect(records, hasLength(1));
      expect(records.single.localIndex, 1);
      expect(records.single.session.interestPaths, submission.interestPaths);
      expect(
        records.single.session.additionalMessage,
        submission.additionalMessage,
      );
      expect(records.single.isPending, isTrue);
      expect(summary.total, 1);
      expect(summary.pending, 1);
      expect(summary.synced, 0);
      expect(summary.lastRegistrationAt, submission.completedAt);
      expect(await secondRepository.checkStorage(), isTrue);

      expect(await secondRepository.getPending(), hasLength(1));
      await secondRepository.markSynced(submission.sessionId);
      expect(await secondRepository.getPending(), isEmpty);
      final syncedSummary = await secondRepository.getSummary();
      expect(syncedSummary.pending, 0);
      expect(syncedSummary.synced, 1);

      await secondRepository.clearAll();
      expect(await secondRepository.getAll(), isEmpty);
      final clearedSummary = await secondRepository.getSummary();
      expect(clearedSummary.total, 0);
      expect(clearedSummary.pending, 0);
      expect(clearedSummary.synced, 0);
      expect(clearedSummary.lastRegistrationAt, isNull);
    },
  );
}
