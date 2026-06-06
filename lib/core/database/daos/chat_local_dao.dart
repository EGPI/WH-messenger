import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/local_conversations.dart';
import '../tables/local_messages.dart';
import '../tables/local_outbox.dart';
import '../tables/local_conversation_participants.dart';
import '../tables/local_users.dart';
import '../tables/local_sync_state.dart';
part 'chat_local_dao.g.dart';

@DriftAccessor(
  tables: [
    LocalConversations,
    LocalMessages,
    LocalOutbox,
    LocalSyncState,
    LocalUsers,
    LocalConversationParticipants,
  ],
)
class ChatLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ChatLocalDaoMixin {
  ChatLocalDao(super.db);

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  Future<void> removeConversationFromList(int conversationId) async {
    await transaction(() async {
      await (delete(localConversations)..where((t) => t.id.equals(conversationId)))
          .go();

      await (delete(localConversationParticipants)
        ..where((t) => t.conversationId.equals(conversationId)))
          .go();
    });
  }

  Stream<List<LocalConversation>> watchConversations() {
    return (select(localConversations)
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.lastMessageAt,
          mode: OrderingMode.desc,
        ),
            (t) => OrderingTerm(
          expression: t.locallyUpdatedAt,
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
        // Server-confirmed messages first.
        // Pending local messages have no serverId, so they go after server messages.
            (t) => OrderingTerm(
          expression: t.serverId.isNull(),
          mode: OrderingMode.asc,
        ),

        // Main ordering source from server.
            (t) => OrderingTerm(
          expression: t.serverId,
          mode: OrderingMode.asc,
        ),

        // Stable local fallback only for pending local messages.
        // This is not phone-clock based.
            (t) => OrderingTerm(
          expression: t.localId,
          mode: OrderingMode.asc,
        ),
      ]))
        .watch();
  }

  Future<void> markLocalMessageDelivered({
    required int serverId,
    required DateTime deliveredAt,
  }) async {
    final message = await findMessageByServerId(serverId);

    if (message == null) return;

    // Never downgrade read back to delivered.
    if (message.status == 'read') return;

    await (update(localMessages)..where((t) => t.serverId.equals(serverId)))
        .write(
      LocalMessagesCompanion(
        status: const Value('delivered'),
        deliveredAt: Value(deliveredAt),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markLocalMessageRead({
    required int serverId,
    required DateTime readAt,
  }) {
    return (update(localMessages)..where((t) => t.serverId.equals(serverId)))
        .write(
      LocalMessagesCompanion(
        status: const Value('read'),
        readAt: Value(readAt),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markMyMessagesReadUpTo({
    required int conversationId,
    required int currentUserId,
    required int lastReadMessageId,
    required DateTime readAt,
  }) {
    return (update(localMessages)
      ..where(
            (t) =>
        t.conversationId.equals(conversationId) &
        t.senderId.equals(currentUserId) &
        t.serverId.isNotNull() &
        t.serverId.isSmallerOrEqualValue(lastReadMessageId),
      ))
        .write(
      LocalMessagesCompanion(
        status: const Value('read'),
        readAt: Value(readAt),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int?> getOldestServerMessageId(int conversationId) async {
    final row = await (select(localMessages)
      ..where(
            (t) =>
        t.conversationId.equals(conversationId) &
        t.serverId.isNotNull(),
      )
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.serverId,
          mode: OrderingMode.asc,
        ),
      ])
      ..limit(1))
        .getSingleOrNull();

    return row?.serverId;
  }

  Future<void> upsertServerMessages(
      List<LocalMessagesCompanion> messages,
      ) async {
    if (messages.isEmpty) return;

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        localMessages,
        messages,
      );
    });
  }

  Future<void> upsertServerMessageSafely(
      LocalMessagesCompanion message, {
        int? serverId,
        String? clientMessageId,
      }) async {
    // 1. Prefer matching by client_message_id.
    // This replaces a local pending message with the server-confirmed message.
    if (clientMessageId != null && clientMessageId.isNotEmpty) {
      final existingByClientMessageId =
      await findMessageByClientMessageId(clientMessageId);

      if (existingByClientMessageId != null) {
        await (update(localMessages)
          ..where((t) => t.localId.equals(existingByClientMessageId.localId)))
            .write(message);
        return;
      }
    }

    // 2. Then match by server_id.
    if (serverId != null) {
      final existingByServerId = await findMessageByServerId(serverId);

      if (existingByServerId != null) {
        await (update(localMessages)
          ..where((t) => t.localId.equals(existingByServerId.localId)))
            .write(message);
        return;
      }
    }

    // 3. New server message.
    await into(localMessages).insert(message);
  }

  Future<void> upsertServerMessagesSafely(
      List<LocalMessagesCompanion> messages, {
        required List<int?> serverIds,
        required List<String?> clientMessageIds,
      }) async {
    if (messages.isEmpty) return;

    await transaction(() async {
      for (var i = 0; i < messages.length; i++) {
        await upsertServerMessageSafely(
          messages[i],
          serverId: serverIds[i],
          clientMessageId: clientMessageIds[i],
        );
      }
    });
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

      // Local-only optimistic conversation preview.
      // This makes the conversation list update immediately like WhatsApp/Telegram.
      await (update(localConversations)
        ..where((t) => t.id.equals(conversationId)))
          .write(
        LocalConversationsCompanion(
          lastMessagePreview: Value(body),
          lastMessageSenderId: Value(senderId),

          // Temporary local value so the pending conversation can move up.
          // It will be replaced with serverReceivedAt when the server confirms.
          lastMessageAt: Value(now),

          locallyUpdatedAt: Value(now),
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
      final existingMessage = await findMessageByClientMessageId(clientMessageId);

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

      if (existingMessage != null) {
        await (update(localConversations)
          ..where((t) => t.id.equals(existingMessage.conversationId)))
            .write(
          LocalConversationsCompanion(
            lastMessageId: Value(serverId),
            lastMessagePreview: Value(existingMessage.body),
            lastMessageSenderId: Value(existingMessage.senderId),
            lastMessageAt: Value(serverReceivedAt),
            locallyUpdatedAt: Value(DateTime.now()),
          ),
        );
      }
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

  Future<LocalConversation?> findConversationById(int conversationId) {
    return (select(localConversations)
      ..where((t) => t.id.equals(conversationId)))
        .getSingleOrNull();
  }

  Future<bool> applySyncedMessageCreated({
    required LocalMessagesCompanion message,
    required int serverId,
    required String? clientMessageId,
    required int conversationId,
    required int senderId,
    required String body,
    required DateTime? serverReceivedAt,
    required bool incrementUnread,
  }) async {
    var insertedNewMessage = false;

    await transaction(() async {
      final existingByServerId = await findMessageByServerId(serverId);

      final existingByClientMessageId =
      clientMessageId == null || clientMessageId.isEmpty
          ? null
          : await findMessageByClientMessageId(clientMessageId);

      final alreadyExists = existingByServerId != null ||
          existingByClientMessageId != null;

      insertedNewMessage = !alreadyExists;

      await upsertServerMessageSafely(
        message,
        serverId: serverId,
        clientMessageId: clientMessageId,
      );

      final currentConversation = await findConversationById(conversationId);

      if (currentConversation != null) {
        await (update(localConversations)
          ..where((t) => t.id.equals(conversationId)))
            .write(
          LocalConversationsCompanion(
            lastMessageId: Value(serverId),
            lastMessagePreview: Value(body),
            lastMessageSenderId: Value(senderId),
            lastMessageAt: Value(serverReceivedAt),
            unreadCount: incrementUnread && insertedNewMessage
                ? Value(currentConversation.unreadCount + 1)
                : Value(currentConversation.unreadCount),
            locallyUpdatedAt: Value(DateTime.now()),
          ),
        );
      }
    });

    return insertedNewMessage;
  }

  Future<bool> hasAlreadyAppliedEvent(int eventId) async {
    final lastEventId = await getLastEventId();
    return eventId <= lastEventId;
  }

  Future<void> applyConversationUpdated({
    required int conversationId,
    required String? type,
    required String? title,
    required int? lastMessageId,
    required String? lastMessagePreview,
    required DateTime? lastMessageAt,
    required int? lastMessageSenderId,
    required int? unreadCount,
    required String? myRole,
    required DateTime? updatedAt,
  }) async {
    final existing = await findConversationById(conversationId);

    if (existing == null) {
      return;
    }

    await (update(localConversations)
      ..where((t) => t.id.equals(conversationId)))
        .write(
      LocalConversationsCompanion(
        type: type == null ? const Value.absent() : Value(type),
        title: Value(title),
        lastMessageId: Value(lastMessageId),
        lastMessagePreview: Value(lastMessagePreview),
        lastMessageAt: Value(lastMessageAt),
        lastMessageSenderId: Value(lastMessageSenderId),
        unreadCount:
        unreadCount == null ? const Value.absent() : Value(unreadCount),
        myRole: Value(myRole),
        updatedAt: Value(updatedAt),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
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

  Future<void> markFailedMessagePendingAgain({
    required String clientMessageId,
  }) async {
    final now = DateTime.now();

    await transaction(() async {
      await (update(localMessages)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .write(
        LocalMessagesCompanion(
          status: const Value('pending'),
          locallyUpdatedAt: Value(now),
        ),
      );

      await (update(localOutbox)
        ..where((t) => t.clientMessageId.equals(clientMessageId)))
          .write(
        LocalOutboxCompanion(
          status: const Value('pending'),
          lastError: const Value(null),
          nextRetryAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> markOutboxPending({
    required String clientMessageId,
    DateTime? nextRetryAt,
    String? lastError,
  }) {
    return (update(localOutbox)
      ..where((t) => t.clientMessageId.equals(clientMessageId)))
        .write(
      LocalOutboxCompanion(
        status: const Value('pending'),
        nextRetryAt: Value(nextRetryAt),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<LocalOutboxData>> getRetryablePendingOutboxItems({
    int limit = 20,
  }) {
    final now = DateTime.now();

    return (select(localOutbox)
      ..where(
            (t) =>
        t.status.equals('pending') &
        (t.nextRetryAt.isNull() | t.nextRetryAt.isSmallerOrEqualValue(now)),
      )
      ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
      ])
      ..limit(limit))
        .get();
  }

  Future<int> getConversationUnreadCount(int conversationId) async {
    final row = await (select(localConversations)
      ..where((t) => t.id.equals(conversationId)))
        .getSingleOrNull();

    return row?.unreadCount ?? 0;
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

  // ---------------------------------------------------------------------------
  // Users / Participants
  // ---------------------------------------------------------------------------

  Future<int> getActiveParticipantCount(int conversationId) async {
    final countExpression = localConversationParticipants.userId.count();

    final query = selectOnly(localConversationParticipants)
      ..addColumns([countExpression])
      ..where(
        localConversationParticipants.conversationId.equals(conversationId) &
        localConversationParticipants.leftAt.isNull(),
      );

    final row = await query.getSingleOrNull();

    return row?.read(countExpression) ?? 0;
  }

  Stream<List<LocalConversationParticipantWithUser>>
  watchConversationParticipantsWithUsersIncludingRemoved(
      int conversationId,
      ) {
    final query = select(localConversationParticipants).join([
      innerJoin(
        localUsers,
        localUsers.id.equalsExp(localConversationParticipants.userId),
      ),
    ])
      ..where(
        localConversationParticipants.conversationId.equals(conversationId),
      )
      ..orderBy([
        OrderingTerm(
          expression: localUsers.name,
          mode: OrderingMode.asc,
        ),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return LocalConversationParticipantWithUser(
          participant: row.readTable(localConversationParticipants),
          user: row.readTable(localUsers),
        );
      }).toList(growable: false);
    });
  }

  Stream<List<LocalConversationParticipantWithUser>>
  watchConversationParticipantsWithUsers(int conversationId) {
    final query = select(localConversationParticipants).join([
      innerJoin(
        localUsers,
        localUsers.id.equalsExp(localConversationParticipants.userId),
      ),
    ])
      ..where(
        localConversationParticipants.conversationId.equals(conversationId) &
        localConversationParticipants.leftAt.isNull(),
      )
      ..orderBy([
        OrderingTerm(
          expression: localConversationParticipants.role,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: localUsers.name,
          mode: OrderingMode.asc,
        ),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return LocalConversationParticipantWithUser(
          participant: row.readTable(localConversationParticipants),
          user: row.readTable(localUsers),
        );
      }).toList(growable: false);
    });
  }

  Future<LocalUser?> findLocalUserById(int userId) {
    return (select(localUsers)..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
  }

  Future<LocalConversationParticipant?> findParticipant({
    required int conversationId,
    required int userId,
  }) {
    return (select(localConversationParticipants)
      ..where(
            (t) => t.conversationId.equals(conversationId) &
        t.userId.equals(userId),
      ))
        .getSingleOrNull();
  }

  Future<void> upsertUser(LocalUsersCompanion user) {
    return into(localUsers).insertOnConflictUpdate(user);
  }

  Future<void> upsertParticipant(
      LocalConversationParticipantsCompanion participant,
      ) {
    return into(localConversationParticipants).insertOnConflictUpdate(
      participant,
    );
  }

  Future<void> upsertConversationDetails({
    required LocalConversationsCompanion conversation,
    required List<LocalUsersCompanion> users,
    required List<LocalConversationParticipantsCompanion> participants,
  }) async {
    await transaction(() async {
      await into(localConversations).insertOnConflictUpdate(conversation);

      if (users.isNotEmpty) {
        await batch((batch) {
          batch.insertAllOnConflictUpdate(
            localUsers,
            users,
          );
        });
      }

      if (participants.isNotEmpty) {
        await batch((batch) {
          batch.insertAllOnConflictUpdate(
            localConversationParticipants,
            participants,
          );
        });
      }
    });
  }

  Future<void> markParticipantRemoved({
    required int conversationId,
    required int userId,
    required DateTime leftAt,
  }) {
    return (update(localConversationParticipants)
      ..where(
            (t) => t.conversationId.equals(conversationId) &
        t.userId.equals(userId),
      ))
        .write(
      LocalConversationParticipantsCompanion(
        leftAt: Value(leftAt),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateParticipantRole({
    required int conversationId,
    required int userId,
    required String role,
  }) {
    return (update(localConversationParticipants)
      ..where(
            (t) => t.conversationId.equals(conversationId) &
        t.userId.equals(userId),
      ))
        .write(
      LocalConversationParticipantsCompanion(
        role: Value(role),
        leftAt: const Value(null),
        locallyUpdatedAt: Value(DateTime.now()),
      ),
    );
  }
}

class LocalConversationParticipantWithUser {
  final LocalConversationParticipant participant;
  final LocalUser user;

  const LocalConversationParticipantWithUser({
    required this.participant,
    required this.user,
  });
}