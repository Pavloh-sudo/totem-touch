import 'visitor_registration.dart';

class InterestSubmission {
  const InterestSubmission({
    required this.id,
    required this.registration,
    required this.pathIds,
    required this.pathTitles,
    required this.createdAt,
  });

  final String id;
  final VisitorRegistration registration;
  final List<String> pathIds;
  final List<String> pathTitles;
  final DateTime createdAt;

  String get finalInterest => pathTitles.last;
}
