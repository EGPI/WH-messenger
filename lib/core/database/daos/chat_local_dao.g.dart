// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_local_dao.dart';

// ignore_for_file: type=lint
mixin _$ChatLocalDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalConversationsTable get localConversations =>
      attachedDatabase.localConversations;
  $LocalMessagesTable get localMessages => attachedDatabase.localMessages;
  $LocalOutboxTable get localOutbox => attachedDatabase.localOutbox;
  $LocalSyncStateTable get localSyncState => attachedDatabase.localSyncState;
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $LocalConversationParticipantsTable get localConversationParticipants =>
      attachedDatabase.localConversationParticipants;
  ChatLocalDaoManager get managers => ChatLocalDaoManager(this);
}

class ChatLocalDaoManager {
  final _$ChatLocalDaoMixin _db;
  ChatLocalDaoManager(this._db);
  $$LocalConversationsTableTableManager get localConversations =>
      $$LocalConversationsTableTableManager(
        _db.attachedDatabase,
        _db.localConversations,
      );
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db.attachedDatabase, _db.localMessages);
  $$LocalOutboxTableTableManager get localOutbox =>
      $$LocalOutboxTableTableManager(_db.attachedDatabase, _db.localOutbox);
  $$LocalSyncStateTableTableManager get localSyncState =>
      $$LocalSyncStateTableTableManager(
        _db.attachedDatabase,
        _db.localSyncState,
      );
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$LocalConversationParticipantsTableTableManager
  get localConversationParticipants =>
      $$LocalConversationParticipantsTableTableManager(
        _db.attachedDatabase,
        _db.localConversationParticipants,
      );
}
