import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:totem_touch/data/local/indexed_db_interest_submission_repository.dart';
import 'package:totem_touch/data/models/registration_session.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/data/remote/registration_api_client.dart';
import 'package:totem_touch/data/repositories/syncing_interest_submission_repository.dart';

void main() {
  test(
    'guarda primero local y marca sincronizado cuando responde la API',
    () async {
      final local = IndexedDbInterestSubmissionRepository(
        factory: idbFactoryMemory,
        databaseName:
            'gpa-sync-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      );
      final remote = _ControlledRemote();
      final repository = SyncingInterestSubmissionRepository(
        local: local,
        remote: remote,
        syncInterval: const Duration(days: 1),
      );
      addTearDown(repository.dispose);
      await repository.initialize();

      await repository.save(_session());
      await remote.started.future;

      var summary = await repository.getSummary();
      expect(summary.total, 1);
      expect(summary.pending, 1);
      expect(summary.synced, 0);

      final synchronization = repository.synchronize();
      remote.release.complete();
      await synchronization;

      summary = await repository.getSummary();
      expect(summary.pending, 0);
      expect(summary.synced, 1);
      expect(remote.submittedIds, [_session().sessionId]);
    },
  );
}

class _ControlledRemote implements RegistrationRemoteGateway {
  final started = Completer<void>();
  final release = Completer<void>();
  final submittedIds = <String>[];

  @override
  Future<void> submit(RegistrationSession session) async {
    submittedIds.add(session.sessionId);
    if (!started.isCompleted) started.complete();
    await release.future;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  void close() {
    if (!release.isCompleted) release.complete();
  }
}

RegistrationSession _session() {
  return RegistrationSession(
    sessionId: 'GPA-20260827-550E8400-E29B-41D4-A716-446655440000',
    startedAt: DateTime(2026, 8, 27, 10),
    personType: VisitorProfile.professional,
    name: 'Pablo',
    company: 'GPA',
    email: 'pablo25@correo.com',
    phone: '6141234567',
    wantsInformation: true,
    interestPath: const [
      'Robótica & Automatización',
      'Automatización con Robots',
    ],
    completedAt: DateTime(2026, 8, 27, 10, 3),
    duration: const Duration(minutes: 3),
    kioskId: 'totem-prueba',
    eventId: 'evento-prueba',
  );
}
