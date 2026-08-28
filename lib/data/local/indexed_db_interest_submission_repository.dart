import 'package:idb_shim/idb.dart';

import '../models/registration_session.dart';
import '../models/stored_registration.dart';
import '../repositories/interest_submission_repository.dart';
import 'indexed_db_factory.dart';

class IndexedDbInterestSubmissionRepository
    implements SyncableInterestSubmissionRepository {
  IndexedDbInterestSubmissionRepository({
    IdbFactory? factory,
    this.databaseName = 'gpa_totem_touch',
  }) : _factory = factory ?? platformIdbFactory;

  static const _databaseVersion = 1;
  static const _storeName = 'registrations';
  static const _completedAtIndex = 'completedAt';
  static const _syncStatusIndex = 'syncStatus';

  final IdbFactory _factory;
  final String databaseName;
  Future<Database>? _database;

  @override
  Future<void> initialize() async {
    await _openDatabase();
  }

  Future<Database> _openDatabase() {
    return _database ??= _factory.open(
      databaseName,
      version: _databaseVersion,
      onUpgradeNeeded: (event) {
        final database = event.database;
        if (database.objectStoreNames.contains(_storeName)) return;
        final store = database.createObjectStore(
          _storeName,
          keyPath: 'sessionId',
        );
        store.createIndex(_completedAtIndex, 'completedAt');
        store.createIndex(_syncStatusIndex, 'syncStatus');
      },
    );
  }

  @override
  Future<void> save(RegistrationSession session) async {
    final database = await _openDatabase();
    final existingTransaction = database.transaction(
      _storeName,
      idbModeReadOnly,
    );
    final existing = await existingTransaction
        .objectStore(_storeName)
        .getObject(session.sessionId);
    await existingTransaction.completed;
    if (existing != null) return;

    final countTransaction = database.transaction(_storeName, idbModeReadOnly);
    final localIndex =
        await countTransaction.objectStore(_storeName).count() + 1;
    await countTransaction.completed;

    final completedAt = session.completedAt;
    final record = StoredRegistration(
      localIndex: localIndex,
      session: session,
      savedAt: DateTime.now(),
      syncStatus: RegistrationSyncStatus.pending,
    );
    final value = record.toJson()
      ..['completedAt'] = completedAt?.toIso8601String() ?? '';

    final writeTransaction = database.transaction(_storeName, idbModeReadWrite);
    await writeTransaction.objectStore(_storeName).add(value);
    await writeTransaction.completed;
  }

  @override
  Future<List<StoredRegistration>> getAll() async {
    final database = await _openDatabase();
    final transaction = database.transaction(_storeName, idbModeReadOnly);
    final values = await transaction.objectStore(_storeName).getAll();
    await transaction.completed;
    final records =
        values
            .map(
              (value) => StoredRegistration.fromJson(
                Map<String, Object?>.from(value as Map),
              ),
            )
            .toList()
          ..sort((a, b) => a.localIndex.compareTo(b.localIndex));
    return List.unmodifiable(records);
  }

  @override
  Future<List<StoredRegistration>> getPending() async {
    final records = await getAll();
    return List.unmodifiable(records.where((record) => record.isPending));
  }

  @override
  Future<void> markSynced(String sessionId) async {
    final database = await _openDatabase();
    final transaction = database.transaction(_storeName, idbModeReadWrite);
    final store = transaction.objectStore(_storeName);
    final stored = await store.getObject(sessionId);
    if (stored != null) {
      final value = Map<String, Object?>.from(stored as Map)
        ..['syncStatus'] = RegistrationSyncStatus.synced.name;
      await store.put(value);
    }
    await transaction.completed;
  }

  @override
  Future<RegistrationStorageSummary> getSummary() async {
    final records = await getAll();
    final pending = records.where((record) => record.isPending).length;
    final latest = records.isEmpty
        ? null
        : records
              .map((record) => record.session.completedAt)
              .whereType<DateTime>()
              .fold<DateTime?>(null, (current, value) {
                if (current == null || value.isAfter(current)) return value;
                return current;
              });
    return RegistrationStorageSummary(
      total: records.length,
      pending: pending,
      synced: records.length - pending,
      lastRegistrationAt: latest,
    );
  }

  @override
  Future<bool> checkStorage() async {
    try {
      final database = await _openDatabase();
      final transaction = database.transaction(_storeName, idbModeReadOnly);
      await transaction.objectStore(_storeName).count();
      await transaction.completed;
      return true;
    } catch (_) {
      return false;
    }
  }
}
