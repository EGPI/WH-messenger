import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/message_send_error_classifier.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../data/message_api.dart';
import '../../data/message_mappers.dart';
import 'message_screen_state.dart';
import '../../../../core/database/daos/chat_local_dao.dart';

final messageScreenControllerProvider = StateNotifierProvider.family<
    MessageScreenController, MessageScreenState, int>(
      (ref, conversationId) {
    return MessageScreenController(
      conversationId: conversationId,
      api: ref.watch(messageApiProvider),
      dao: ref.watch(chatLocalDaoProvider),
    );
  },
);

class MessageScreenController extends StateNotifier<MessageScreenState> {
  final int conversationId;
  final MessageApi api;
  final ChatLocalDao dao;

  MessageScreenController({
    required this.conversationId,
    required this.api,
    required this.dao,
  }) : super(const MessageScreenState.initial());

  Future<void> openConversation() async {
    if (state.isInitialSyncing) return;

    state = state.copyWith(
      isInitialSyncing: true,
      clearError: true,
    );

    try {
      final response = await api.fetchMessages(
        conversationId: conversationId,
        limit: 30,
      );

      debugPrint(
        'MessageScreen: fetched ${response.data.length} messages for conversation $conversationId',
      );

      for (final message in response.data) {
        debugPrint(
          'MessageScreen: server message id=${message.id}, conversationId=${message.conversationId}, body=${message.body}',
        );
      }

      final companions =
      response.data.map((message) => message.toLocalCompanion()).toList();

      await dao.upsertServerMessagesSafely(
        companions,
        serverIds: response.data.map((message) => message.id).toList(),
        clientMessageIds:
        response.data.map((message) => message.clientMessageId).toList(),
      );

      debugPrint(
        'MessageScreen: upserted ${companions.length} messages into Drift',
      );

      final unreadCount = await dao.getConversationUnreadCount(conversationId);

      if (unreadCount > 0) {
        await markRead();
      }

      state = state.copyWith(
        isInitialSyncing: false,
        hasMoreOlder: response.meta.hasMore,
      );
    } catch (error, stackTrace) {
      debugPrint('MessageScreen openConversation error: $error');
      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        isInitialSyncing: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> loadOlderMessages() async {
    if (state.isLoadingOlder || !state.hasMoreOlder) return;

    state = state.copyWith(
      isLoadingOlder: true,
      clearError: true,
    );

    try {
      final oldestServerMessageId =
      await dao.getOldestServerMessageId(conversationId);

      if (oldestServerMessageId == null) {
        state = state.copyWith(
          isLoadingOlder: false,
          hasMoreOlder: false,
        );
        return;
      }

      final response = await api.fetchMessages(
        conversationId: conversationId,
        beforeMessageId: oldestServerMessageId,
        limit: 30,
      );

      await dao.upsertServerMessagesSafely(
        response.data.map((message) => message.toLocalCompanion()).toList(),
        serverIds: response.data.map((message) => message.id).toList(),
        clientMessageIds:
        response.data.map((message) => message.clientMessageId).toList(),
      );

      state = state.copyWith(
        isLoadingOlder: false,
        hasMoreOlder: response.meta.hasMore,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingOlder: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> markRead() async {
    try {
      await api.markConversationRead(conversationId: conversationId);
      await dao.markConversationReadLocally(conversationId);
    } catch (_) {
      // Do not block message screen if read-marking fails.
      // The next open/sync can retry this.
    }
  }

  Future<void> sendMessage({
    required int senderId,
    required String body,
  }) async {
    final trimmedBody = body.trim();

    if (trimmedBody.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Message cannot be empty.',
      );
      return;
    }

    final clientMessageId = const Uuid().v4();

    // 1. Save locally first.
    // This immediately updates the UI because MessageScreen reads from Drift.
    await dao.insertPendingMessage(
      conversationId: conversationId,
      senderId: senderId,
      clientMessageId: clientMessageId,
      body: trimmedBody,
    );

    state = state.copyWith(
      isSending: true,
      clearError: true,
    );

    try {
      // 2. Send to Laravel using the same client_message_id.
      final serverMessage = await api.sendMessage(
        conversationId: conversationId,
        clientMessageId: clientMessageId,
        body: trimmedBody,
      );

      final serverReceivedAt = serverMessage.serverReceivedAt ??
          serverMessage.sentAt ??
          serverMessage.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      // 3. Update local pending row to sent.
      await dao.markMessageAsSent(
        clientMessageId: clientMessageId,
        serverId: serverMessage.id,
        serverSequence: serverMessage.serverSequence ?? serverMessage.id,
        serverReceivedAt: serverReceivedAt,
      );

      state = state.copyWith(
        isSending: false,
      );
    } catch (error) {
      final action = classifySendFailure(error);
      final message = sendFailureMessage(error);

      if (action == SendFailureAction.markFailed) {
        await dao.markMessageFailed(
          clientMessageId: clientMessageId,
          error: message,
        );
      } else {
        await dao.rescheduleOutboxItem(
          clientMessageId: clientMessageId,
          error: message,
          nextRetryAt: DateTime.now().add(const Duration(seconds: 5)),
        );
      }

      state = state.copyWith(
        isSending: false,
        errorMessage: message,
      );
    }
  }

  bool _shouldMarkSendFailed(Object error) {
    if (error is! DioException) {
      return true;
    }

    final statusCode = error.response?.statusCode;

    // Validation / permission / membership errors should not retry forever.
    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404 ||
        statusCode == 422) {
      return true;
    }

    // No internet, timeout, or server error should remain pending for retry.
    return false;
  }

  String _sendErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Message saved locally. It will be retried later.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'Server unavailable. Message will be retried later.';
      }
    }

    return 'Could not send message.';
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
        return 'Connection timeout. Please try again.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to the server.';
      }
    }

    return error.toString();
  }
}