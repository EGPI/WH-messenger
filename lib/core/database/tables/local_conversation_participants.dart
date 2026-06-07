import 'package:drift/drift.dart';

class LocalConversationParticipants extends Table {
  IntColumn get conversationId => integer()();

  IntColumn get userId => integer()();

  /// owner, admin, member
  TextColumn get role => text().nullable()();

  DateTimeColumn get joinedAt => dateTime().nullable()();

  /// Null means active participant.
  /// Non-null means removed/left.
  DateTimeColumn get leftAt => dateTime().nullable()();

  DateTimeColumn get locallyUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {
    conversationId,
    userId,
  };
}