import '../models/registration_session.dart';

abstract interface class InterestSubmissionRepository {
  Future<void> save(RegistrationSession session);
}
