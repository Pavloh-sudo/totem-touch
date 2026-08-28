import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/registration_session.dart';
import '../models/stored_registration.dart';
import '../remote/registration_api_client.dart';
import 'interest_submission_repository.dart';

class SyncingInterestSubmissionRepository
    implements InterestSubmissionRepository {
  factory SyncingInterestSubmissionRepository({
    required SyncableInterestSubmissionRepository local,
    required RegistrationRemoteGateway remote,
    Duration syncInterval = const Duration(seconds: 30),
  }) {
    return SyncingInterestSubmissionRepository._(local, remote, syncInterval);
  }

  SyncingInterestSubmissionRepository._(
    this._local,
    this._remote,
    this.syncInterval,
  );

  final SyncableInterestSubmissionRepository _local;
  final RegistrationRemoteGateway _remote;
  final Duration syncInterval;

  Timer? _timer;
  Future<void>? _syncInFlight;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    await _local.initialize();
    if (_disposed) return;
    _timer ??= Timer.periodic(syncInterval, (_) => unawaited(synchronize()));
    unawaited(synchronize());
  }

  @override
  Future<void> save(RegistrationSession session) async {
    await _local.save(session);
    if (!_disposed) unawaited(synchronize());
  }

  @override
  Future<void> synchronize() async {
    if (_disposed) return;
    final current = _syncInFlight;
    if (current != null) return current;

    final operation = _synchronizePending();
    _syncInFlight = operation;
    try {
      await operation;
    } finally {
      if (identical(_syncInFlight, operation)) _syncInFlight = null;
    }
  }

  Future<void> _synchronizePending() async {
    final pending = await _local.getPending();
    for (final record in pending) {
      if (_disposed) return;
      try {
        await _remote.submit(record.session);
        await _local.markSynced(record.session.sessionId);
      } on Object catch (error) {
        debugPrint('Sincronización pendiente: $error');
        return;
      }
    }
  }

  @override
  Future<List<StoredRegistration>> getAll() => _local.getAll();

  @override
  Future<RegistrationStorageSummary> getSummary() => _local.getSummary();

  @override
  Future<bool> checkStorage() async {
    return _local.checkStorage();
  }

  @override
  Future<bool> checkServer() => _remote.isAvailable();

  @override
  Future<void> clearAll() => _local.clearAll();

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _remote.close();
  }
}
