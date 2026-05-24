import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables/local_conversations.dart';
import 'tables/local_messages.dart';
import 'tables/local_outbox.dart';
import 'tables/local_sync_state.dart';
import 'daos/chat_local_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalConversations,
    LocalMessages,
    LocalOutbox,
    LocalSyncState,
  ],
  daos: [
    ChatLocalDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}