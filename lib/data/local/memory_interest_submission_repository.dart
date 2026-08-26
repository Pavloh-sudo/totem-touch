import '../models/interest_submission.dart';
import '../repositories/interest_submission_repository.dart';

class MemoryInterestSubmissionRepository
    implements InterestSubmissionRepository {
  final List<InterestSubmission> _submissions = [];
  final Set<String> _savedIds = {};

  List<InterestSubmission> get submissions => List.unmodifiable(_submissions);

  @override
  Future<void> save(InterestSubmission submission) async {
    if (!_savedIds.add(submission.id)) return;
    _submissions.add(submission);
  }
}
