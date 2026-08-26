import 'registration_session.dart';

enum RegistrationSyncStatus { pending, synced }

class StoredRegistration {
  const StoredRegistration({
    required this.localIndex,
    required this.session,
    required this.savedAt,
    required this.syncStatus,
  });

  final int localIndex;
  final RegistrationSession session;
  final DateTime savedAt;
  final RegistrationSyncStatus syncStatus;

  bool get isPending => syncStatus == RegistrationSyncStatus.pending;

  StoredRegistration markSynced() {
    return StoredRegistration(
      localIndex: localIndex,
      session: session,
      savedAt: savedAt,
      syncStatus: RegistrationSyncStatus.synced,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'sessionId': session.sessionId,
      'localIndex': localIndex,
      'savedAt': savedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'session': session.toJson(),
    };
  }

  factory StoredRegistration.fromJson(Map<String, Object?> json) {
    return StoredRegistration(
      localIndex: (json['localIndex']! as num).toInt(),
      session: RegistrationSession.fromJson(
        Map<String, Object?>.from(json['session']! as Map),
      ),
      savedAt: DateTime.parse(json['savedAt']! as String),
      syncStatus: RegistrationSyncStatus.values.byName(
        json['syncStatus']! as String,
      ),
    );
  }
}
