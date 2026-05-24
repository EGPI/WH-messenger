import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/local_conversations.dart';
import '../tables/local_messages.dart';
import '../tables/local_outbox.dart';
import '../tables/local_sync_state.dart';
part 'chat_local_dao.g.dart';

@DriftAccessor(
  tables: [
    LocalConversations,
    LocalMessages,
    LocalOutbox,
    LocalSyncState,
  ],
)
class ChatLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ChatLocalDaoMixin {
  ChatLocalDao(super.db);

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  Stream<List<LocalConversation>> watchConversations() {
    return (select(localConversations)
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.lastMessageAt,
          mode: OrderingMode.desc,
        ),
      ]))
        .watch();
  }

  Future<void> upsertConversation(LocalConversationsCompanion conversation) {
    return into(localConversations).insertOnConflictUpdate(conversation);
  }

  Future<void> upsertConversations(
      List<LocalConversationsCompanion> conversations,
      ) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        localConversations,
        conversations,
      );
    });
  }

  Future<void> updateConversationUnreadCount({
    required int conversationId,
    required int unreadCount,
  }) {
    return (update(localConversations)
      ..where((t) => t.id.equals(conversationId)))
        .write(
      LocalConversationsCompanion(
        unreadCount: Value(unreadCount),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConversationReadLocally(int conversationId) {
    return (update(localConversations)
      ..where((t) => t.id.equals(conversationId)))
        .write(
      LocalConversationsCompanion(
        unreadCount: const Value(0),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  Stream<List<LocalMessage>> watchMessages(int conversationId) {
    return (select(localMessages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.serverSequence,
          mode: OrderingMode.asc,
        ),
            (t) => OrderingTerm(
          expression: t.createdAt,
          mode: OrderingMode.asc,
        ),
            (t) => OrderingTerm(
          expression: t.localId,
          mode: OrderingMode.asc,
        ),
      ]))
        .watch();
  }

  Future<void> insertPendingMessage({
    required int conversationId,
    required int senderId,
    required String clientMessageId,
    required String body,
  }) async {
    final now = DateTime.now();

    await transaction(() async {
      await into(localMessages).insert(
        LocalMessagesCompanion.insert(
          conversationId: conversationId,
          senderId: senderId,
          body: body,
          clientMessageId: Value(clientMessageId),
          status: const Value('pending'),
          createdAt: now,
        ),
      );

      await into(localOutbox).insert(
        LocalOutboxCompanion.insert(
          conversationId: conversationId,
          clientMessageId: clientMessageId,
          body: body,
          status: const Value('pending'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> markMessageAsSent({
    required String clientMessageId,
    required int serverId,
    required int serverSequence,
    required DateTime serverReceivedAt,
  }) async {
    await transaction(() async {
      await (update(localMessages)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .write(
        LocalMessagesCompanion(
          serverId: Value(serverId),
          serverSequence: Value(serverSequence),
          serverReceivedAt: Value(serverReceivedAt),
          status: const Value('sent'),
          locallyUpdatedAt: Value(DateTime.now()),
        ),
      );

      await (delete(localOutbox)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .go();
    });
  }

  Future<void> markMessageFailed({
    required String clientMessageId,
    required String error,
  }) async {
    final now = DateTime.now();

    await transaction(() async {
      await (update(localMessages)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .write(
        LocalMessagesCompanion(
          status: const Value('failed'),
          locallyUpdatedAt: Value(now),
        ),
      );

      await (update(localOutbox)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .write(
        LocalOutboxCompanion(
          status: const Value('failed'),
          lastError: Value(error),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> upsertServerMessage(LocalMessagesCompanion message) {
    return into(localMessages).insertOnConflictUpdate(message);
  }

  Future<LocalMessage?> findMessageByClientMessageId(String clientMessageId) {
    return (select(localMessages)
      ..where((t) => t.clientMessageId.equals(clientMessageId)))
        .getSingleOrNull();
  }

  Future<LocalMessage?> findMessageByServerId(int serverId) {
    return (select(localMessages)..where((t) => t.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Outbox
  // ---------------------------------------------------------------------------

  Future<List<LocalOutboxData>> getPendingOutboxItems() {
    return (select(localOutbox)
      ..where((t) => t.status.equals('pending') | t.status.equals('failed'))
      ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
      ]))
        .get();
  }

  Future<void> markOutboxSending(String clientMessageId) {
    return (update(localOutbox)
      ..where((t) => t.clientMessageId.equals(clientMessageId)))
        .write(
      LocalOutboxCompanion(
        status: const Value('sending'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> rescheduleOutboxItem({
    required String clientMessageId,
    required String error,
    required DateTime nextRetryAt,
  }) async {
    final current = await (select(localOutbox)
      ..where((t) => t.clientMessageId.equals(clientMessageId)))
        .getSingleOrNull();

    if (current == null) return;

    await (update(localOutbox)
      ..where((t) => t.clientMessageId.equals(clientMessageId)))
        .write(
      LocalOutboxCompanion(
        status: const Value('pending'),
        attemptCount: Value(current.attemptCount + 1),
        lastError: Value(error),
        nextRetryAt: Value(nextRetryAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sync state
  // ---------------------------------------------------------------------------

  Future<int> getLastEventId() async {
    final row = await (select(localSyncState)
      ..where((t) => t.key.equals('last_event_id')))
        .getSingleOrNull();

    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<void> setLastEventId(int eventId) {
    return into(localSyncState).insertOnConflictUpdate(
      LocalSyncStateCompanion.insert(
        key: 'last_event_id',
        value: Value(eventId.toString()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String?> getSyncValue(String key) async {
    final row = await (select(localSyncState)..where((t) => t.key.equals(key)))
        .getSingleOrNull();

    return row?.value;
  }

  Future<void> setSyncValue({
    required String key,
    required String? value,
  }) {
    return into(localSyncState).insertOnConflictUpdate(
      LocalSyncStateCompanion.insert(
        key: key,
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}