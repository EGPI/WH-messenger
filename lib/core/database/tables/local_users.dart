import 'package:drift/drift.dart';

class LocalUsers extends Table {
  /// Server user ID from Laravel.
  IntColumn get id => integer()();

  TextColumn get name => text()();
  TextColumn get email => text()();

  TextColumn get avatarUrl => text().nullable()();
  TextColumn get phone => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  DateTimeColumn get locallyUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}