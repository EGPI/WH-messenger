import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables/local_conversation_participants.dart';
import 'tables/local_conversations.dart';
import 'tables/local_messages.dart';
import 'tables/local_outbox.dart';
import 'tables/local_sync_state.dart';
import 'tables/local_users.dart';
import 'daos/chat_local_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalConversations,
    LocalMessages,
    LocalOutbox,
    LocalSyncState,
    LocalUsers,
    LocalConversationParticipants,
  ],
  daos: [
    ChatLocalDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(localUsers);
          await migrator.createTable(localConversationParticipants);
        }
      },
    );
  }
}