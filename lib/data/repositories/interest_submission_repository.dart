import '../models/interest_submission.dart';

abstract interface class InterestSubmissionRepository {
  Future<void> save(InterestSubmission submission);
}
