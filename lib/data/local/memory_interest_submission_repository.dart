import '../models/registration_session.dart';
import '../models/stored_registration.dart';
import '../repositories/interest_submission_repository.dart';

class MemoryInterestSubmissionRepository
    implements InterestSubmissionRepository {
  final List<StoredRegistration> _records = [];
  final Set<String> _savedIds = {};

  List<RegistrationSession> get submissions =>
      List.unmodifiable(_records.map((record) => record.session));

  @override
  Future<void> initialize() async {}

  @override
  Future<void> save(RegistrationSession session) async {
    if (!_savedIds.add(session.sessionId)) return;
    _records.add(
      StoredRegistration(
        localIndex: _records.length + 1,
        session: session,
        savedAt: DateTime.now(),
        syncStatus: RegistrationSyncStatus.pending,
      ),
    );
  }

  @override
  Future<List<StoredRegistration>> getAll() async {
    return List.unmodifiable(_records);
  }

  @override
  Future<RegistrationStorageSummary> getSummary() async {
    final pending = _records.where((record) => record.isPending).length;
    final last = _records.isEmpty ? null : _records.last.session.completedAt;
    return RegistrationStorageSummary(
      total: _records.length,
      pending: pending,
      synced: _records.length - pending,
      lastRegistrationAt: last,
    );
  }

  @override
  Future<bool> checkStorage() async {
    return true;
  }
}
