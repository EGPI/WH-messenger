import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../data/conversation_api.dart';
import '../../data/conversation_mappers.dart';
import 'conversations_sync_state.dart';

final conversationsControllerProvider =
NotifierProvider<ConversationsController, ConversationsSyncState>(
  ConversationsController.new,
);

class ConversationsController extends Notifier<ConversationsSyncState> {
  late final ConversationApi _api;
  late final _dao = ref.read(chatLocalDaoProvider);

  @override
  ConversationsSyncState build() {
    _api = ref.read(conversationApiProvider);
    return const ConversationsSyncState.initial();
  }

  Future<void> syncConversations() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      clearError: true,
    );

    try {
      final response = await _api.getConversations(perPage: 50);

      final companions = response.data
          .map((conversation) => conversation.toLocalCompanion())
          .toList();

      await _dao.upsertConversations(companions);

      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: _friendlyError(error),
      );
    }
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

      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to server.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timeout. Please try again.';
      }
    }

    return 'Could not sync conversations.';
  }
}