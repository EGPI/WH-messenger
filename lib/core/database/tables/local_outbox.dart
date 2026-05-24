import 'package:drift/drift.dart';

class LocalOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get conversationId => integer()();

  TextColumn get clientMessageId => text().unique()();

  TextColumn get body => text()();

  /// pending, sending, failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get nextRetryAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}