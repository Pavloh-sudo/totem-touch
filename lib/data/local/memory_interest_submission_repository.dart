import '../models/registration_session.dart';
import '../repositories/interest_submission_repository.dart';

class MemoryInterestSubmissionRepository
    implements InterestSubmissionRepository {
  final List<RegistrationSession> _submissions = [];
  final Set<String> _savedIds = {};

  List<RegistrationSession> get submissions => List.unmodifiable(_submissions);

  @override
  Future<void> save(RegistrationSession session) async {
    if (!_savedIds.add(session.sessionId)) return;
    _submissions.add(session);
  }
}
