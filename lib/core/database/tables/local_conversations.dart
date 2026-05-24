import 'package:drift/drift.dart';

class LocalConversations extends Table {
  /// Server conversation ID from Laravel.
  IntColumn get id => integer()();

  TextColumn get type => text()();
  TextColumn get title => text().nullable()();

  TextColumn get lastMessagePreview => text().nullable()();
  IntColumn get lastMessageId => integer().nullable()();
  IntColumn get lastMessageSenderId => integer().nullable()();

  DateTimeColumn get lastMessageAt => dateTime().nullable()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  TextColumn get myRole => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  DateTimeColumn get locallyUpdatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}