import '../models/registration_session.dart';
import '../models/stored_registration.dart';

class RegistrationStorageSummary {
  const RegistrationStorageSummary({
    required this.total,
    required this.pending,
    required this.synced,
    required this.lastRegistrationAt,
  });

  final int total;
  final int pending;
  final int synced;
  final DateTime? lastRegistrationAt;
}

abstract interface class InterestSubmissionRepository {
  Future<void> initialize();

  Future<void> save(RegistrationSession session);

  Future<List<StoredRegistration>> getAll();

  Future<RegistrationStorageSummary> getSummary();

  Future<bool> checkStorage();
}

abstract interface class SyncableInterestSubmissionRepository
    implements InterestSubmissionRepository {
  Future<List<StoredRegistration>> getPending();

  Future<void> markSynced(String sessionId);
}
