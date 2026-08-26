import 'visitor_registration.dart';

class RegistrationSession {
  const RegistrationSession({
    required this.sessionId,
    required this.startedAt,
    required this.personType,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.wantsInformation,
    required this.interestPath,
    this.additionalInterestPaths = const [],
    required this.completedAt,
    required this.duration,
    required this.kioskId,
    required this.eventId,
  });

  final String sessionId;
  final DateTime startedAt;
  final VisitorProfile? personType;
  final String name;
  final String company;
  final String email;
  final String phone;
  final bool wantsInformation;
  final List<String> interestPath;
  final List<List<String>> additionalInterestPaths;
  final DateTime? completedAt;
  final Duration? duration;
  final String kioskId;
  final String eventId;

  bool get isCompleted => completedAt != null;
  List<List<String>> get interestPaths => List.unmodifiable([
    if (interestPath.isNotEmpty) interestPath,
    ...additionalInterestPaths,
  ]);
  String get finalInterest => interestPaths.last.last;

  Map<String, Object?> toJson() {
    return {
      'sessionId': sessionId,
      'startedAt': startedAt.toIso8601String(),
      'personType': personType?.name,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'wantsInformation': wantsInformation,
      'interestPath': interestPath,
      'interestPaths': interestPaths,
      'completedAt': completedAt?.toIso8601String(),
      'durationMilliseconds': duration?.inMilliseconds,
      'kioskId': kioskId,
      'eventId': eventId,
    };
  }

  factory RegistrationSession.fromJson(Map<String, Object?> json) {
    final profileName = json['personType'] as String?;
    final storedPaths = switch (json['interestPaths']) {
      final List value =>
        value
            .map(
              (path) =>
                  List<String>.unmodifiable((path as List).cast<String>()),
            )
            .toList(growable: false),
      _ => <List<String>>[
        List<String>.unmodifiable(
          (json['interestPath']! as List).cast<String>(),
        ),
      ],
    };
    return RegistrationSession(
      sessionId: json['sessionId']! as String,
      startedAt: DateTime.parse(json['startedAt']! as String),
      personType: profileName == null
          ? null
          : VisitorProfile.values.byName(profileName),
      name: json['name']! as String,
      company: json['company']! as String,
      email: json['email']! as String,
      phone: json['phone']! as String,
      wantsInformation: json['wantsInformation']! as bool,
      interestPath: storedPaths.isEmpty ? const [] : storedPaths.first,
      additionalInterestPaths: storedPaths.length <= 1
          ? const []
          : List.unmodifiable(storedPaths.skip(1)),
      completedAt: switch (json['completedAt']) {
        final String value => DateTime.parse(value),
        _ => null,
      },
      duration: switch (json['durationMilliseconds']) {
        final num value => Duration(milliseconds: value.toInt()),
        _ => null,
      },
      kioskId: json['kioskId']! as String,
      eventId: json['eventId']! as String,
    );
  }

  RegistrationSession withRegistration(VisitorRegistration registration) {
    return RegistrationSession(
      sessionId: sessionId,
      startedAt: startedAt,
      personType: registration.profile,
      name: registration.name,
      company: registration.organization,
      email: registration.email,
      phone: registration.phone,
      wantsInformation: registration.acceptsInformation,
      interestPath: interestPath,
      additionalInterestPaths: additionalInterestPaths,
      completedAt: completedAt,
      duration: duration,
      kioskId: kioskId,
      eventId: eventId,
    );
  }

  RegistrationSession complete({
    required List<String> path,
    required DateTime at,
  }) {
    return completeAll(paths: [path], at: at);
  }

  RegistrationSession completeAll({
    required List<List<String>> paths,
    required DateTime at,
  }) {
    final immutablePaths = paths
        .map((path) => List<String>.unmodifiable(path))
        .toList(growable: false);
    return RegistrationSession(
      sessionId: sessionId,
      startedAt: startedAt,
      personType: personType,
      name: name,
      company: company,
      email: email,
      phone: phone,
      wantsInformation: wantsInformation,
      interestPath: immutablePaths.first,
      additionalInterestPaths: List.unmodifiable(immutablePaths.skip(1)),
      completedAt: at,
      duration: at.difference(startedAt),
      kioskId: kioskId,
      eventId: eventId,
    );
  }
}
