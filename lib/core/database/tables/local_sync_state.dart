import 'package:drift/drift.dart';

class LocalSyncState extends Table {
  /// Example keys:
  /// last_event_id
  /// last_full_conversation_sync_at
  /// device_id
  TextColumn get key => text()();

  TextColumn get value => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}