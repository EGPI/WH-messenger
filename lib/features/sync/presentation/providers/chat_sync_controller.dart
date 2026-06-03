import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../../core/database/daos/chat_local_dao.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../conversations/presentation/providers/conversations_controller.dart';
import '../../../messages/data/message_api.dart';
import '../../../messages/presentation/providers/message_screen_providers.dart';
import '../../../messages/presentation/providers/outbox_retry_worker.dart';
import '../../data/sync_api.dart';
import '../../data/sync_mappers.dart';
import '../../data/sync_models.dart';
import 'chat_sync_state.dart';

final chatSyncControllerProvider =
NotifierProvider<ChatSyncController, ChatSyncState>(
  ChatSyncController.new,
);

class ChatSyncController extends Notifier<ChatSyncState> {
  late final SyncApi _syncApi;
  late final MessageApi _messageApi;
  late final ChatLocalDao _dao;

  @override
  ChatSyncState build() {
    _syncApi = ref.read(syncApiProvider);
    _messageApi = ref.read(messageApiProvider);
    _dao = ref.read(chatLocalDaoProvider);

    return const ChatSyncState.initial();
  }

  Future<void> syncNow({
    bool flushOutboxAfter = true,
  }) async {
    if (state.isSyncing) return;

    final currentUserId = ref.read(
      authControllerProvider.select((state) => state.user?.id),
    );

    if (currentUserId == null) return;

    state = state.copyWith(
      isSyncing: true,
      clearError: true,
    );

    try {
      var afterEventId = await _dao.getLastEventId();
      var keepGoing = true;

      while (keepGoing) {
        final response = await _syncApi.getSyncEvents(
          afterEventId: afterEventId,
          limit: 100,
        );

        for (final event in response.events) {
          final alreadyApplied = await _dao.hasAlreadyAppliedEvent(event.id);

          if (alreadyApplied) {
            continue;
          }

          await _applyEvent(
            event: event,
            currentUserId: currentUserId,
          );

          await _dao.setLastEventId(event.id);
          afterEventId = event.id;
        }

        if (response.events.isEmpty) {
          await _dao.setLastEventId(response.nextEventId);
          afterEventId = response.nextEventId;
        }

        keepGoing = response.hasMore;
      }

      if (flushOutboxAfter) {
        await ref
            .read(outboxRetryWorkerProvider.notifier)
            .flushPendingOutbox();
      }

      state = state.copyWith(
        isSyncing: false,
        lastAppliedEventId: afterEventId,
      );
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> _applyEvent({
    required SyncEventModel event,
    required int currentUserId,
  }) async {
    switch (event.eventType) {
      case 'message.created':
        await _applyMessageCreated(
          event: event,
          currentUserId: currentUserId,
        );
        return;

      case 'conversation.updated':
        await _applyConversationUpdated(event);
        return;

      case 'message.delivered':
        await _applyMessageDelivered(event);
        return;

      case 'message.read':
        await _applyMessageRead(
          event: event,
          currentUserId: currentUserId,
        );
        return;

      case 'participant.added':
      case 'participant.removed':
      case 'participant.role_changed':
      // For now, safest lightweight behavior:
      // refresh conversation metadata only when membership/role changes.
        await ref
            .read(conversationsControllerProvider.notifier)
            .syncConversations();
        return;

      default:
        return;
    }
  }

  Future<void> applyRealtimeEvent(SyncEventModel event) async {
    final currentUserId = ref.read(
      authControllerProvider.select((state) => state.user?.id),
    );

    if (currentUserId == null) return;

    final alreadyApplied = await _dao.hasAlreadyAppliedEvent(event.id);

    if (alreadyApplied) {
      return;
    }

    await _applyEvent(
      event: event,
      currentUserId: currentUserId,
    );

    await _dao.setLastEventId(event.id);

    state = state.copyWith(
      lastAppliedEventId: event.id,
    );
  }

  Future<void> _applyMessageCreated({
    required SyncEventModel event,
    required int currentUserId,
  }) async {
    final companion = event.toMessageCreatedCompanion();

    if (companion == null) return;

    final conversationId = event.messageCreatedConversationId;
    final messageId = event.messageCreatedMessageId;
    final senderId = event.messageCreatedSenderId;

    if (conversationId == null || messageId == null || senderId == null) {
      return;
    }

    final existingConversation =
    await _dao.findConversationById(conversationId);

    if (existingConversation == null) {
      await ref
          .read(conversationsControllerProvider.notifier)
          .syncConversations();
    }

    final openConversationId = ref.read(openConversationIdProvider);
    final isMine = senderId == currentUserId;
    final isOpenConversation = openConversationId == conversationId;

    final shouldIncrementUnread = !isMine && !isOpenConversation;

    final insertedNewMessage = await _dao.applySyncedMessageCreated(
      message: companion,
      serverId: messageId,
      clientMessageId: event.messageCreatedClientMessageId,
      conversationId: conversationId,
      senderId: senderId,
      body: event.messageCreatedBody,
      serverReceivedAt: event.messageCreatedServerReceivedAt,
      incrementUnread: shouldIncrementUnread,
    );

    if (!insertedNewMessage) return;

    if (isMine) return;

    if (isOpenConversation) {
      await _messageApi.markConversationRead(
        conversationId: conversationId,
      );

      await _dao.markConversationReadLocally(conversationId);
      return;
    }

    await _messageApi.markMessageDelivered(
      messageId: messageId,
    );
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Sync timeout. Please try again.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to server.';
      }
    }

    return 'Could not sync missed events.';
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString();
    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  Future<void> _applyConversationUpdated(SyncEventModel event) async {
    final payload = event.payload;

    final conversationId =
        _parseInt(payload['conversation_id']) ??
            _parseInt(payload['id']) ??
            event.conversationId;

    if (conversationId == null) return;

    final existing = await _dao.findConversationById(conversationId);

    if (existing == null) {
      await ref
          .read(conversationsControllerProvider.notifier)
          .syncConversations();
      return;
    }

    final openConversationId = ref.read(openConversationIdProvider);
    final isOpenConversation = openConversationId == conversationId;

    final incomingUnreadCount = _parseInt(payload['unread_count']);

    await _dao.applyConversationUpdated(
      conversationId: conversationId,
      type: payload['type']?.toString(),
      title: payload['title']?.toString(),
      lastMessageId: _parseInt(payload['last_message_id']),
      lastMessagePreview: payload['last_message_preview']?.toString(),
      lastMessageAt: _parseDateTime(payload['last_message_at']),
      lastMessageSenderId: _parseInt(payload['last_message_sender_id']),
      unreadCount: isOpenConversation ? 0 : incomingUnreadCount,
      myRole: payload['my_role']?.toString(),
      updatedAt: _parseDateTime(payload['updated_at']),
    );
  }

  Future<void> _applyMessageDelivered(SyncEventModel event) async {
    final payload = event.payload;

    final messageId =
        _parseInt(payload['message_id']) ?? event.messageId;

    final deliveredAt =
        _parseDateTime(payload['delivered_at']) ??
            event.occurredAt ??
            event.createdAt ??
            DateTime.now();

    if (messageId == null) return;

    await _dao.markLocalMessageDelivered(
      serverId: messageId,
      deliveredAt: deliveredAt,
    );
  }

  Future<void> _applyMessageRead({
    required SyncEventModel event,
    required int currentUserId,
  }) async {
    final payload = event.payload;

    final readByUserId = _parseInt(payload['read_by_user_id']);

    // Important:
    // If I am the user who opened/read the conversation, this event should NOT
    // turn my own sent messages into blue ticks.
    //
    // Blue ticks mean "the other participant read my message".
    if (readByUserId == null || readByUserId == currentUserId) {
      return;
    }

    final conversationId =
        _parseInt(payload['conversation_id']) ?? event.conversationId;

    final lastReadMessageId =
        _parseInt(payload['last_read_message_id']) ?? event.messageId;

    final markedReadCount = _parseInt(payload['marked_read_count']) ?? 0;

    // If backend says no receipts changed, do not update message ticks.
    if (markedReadCount <= 0) {
      return;
    }

    final readAt =
        _parseDateTime(payload['read_at']) ??
            event.occurredAt ??
            event.createdAt ??
            DateTime.now();

    if (conversationId == null || lastReadMessageId == null) return;

    await _dao.markMyMessagesReadUpTo(
      conversationId: conversationId,
      currentUserId: currentUserId,
      lastReadMessageId: lastReadMessageId,
      readAt: readAt,
    );
  }
}