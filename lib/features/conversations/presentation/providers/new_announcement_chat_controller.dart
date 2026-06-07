import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../data/conversation_api.dart';
import '../../data/conversation_mappers.dart';
import '../../data/user_search_models.dart';
import 'new_announcement_chat_state.dart';

final newAnnouncementChatControllerProvider = AutoDisposeNotifierProvider<
    NewAnnouncementChatController, NewAnnouncementChatState>(
  NewAnnouncementChatController.new,
);

class NewAnnouncementChatController
    extends AutoDisposeNotifier<NewAnnouncementChatState> {
  late final ConversationApi _api;
  late final _dao = ref.read(chatLocalDaoProvider);

  @override
  NewAnnouncementChatState build() {
    _api = ref.read(conversationApiProvider);
    return const NewAnnouncementChatState.initial();
  }

  Future<void> searchUsers(String query) async {
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      state = state.copyWith(
        isSearching: false,
        users: const [],
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      isSearching: true,
      clearError: true,
    );

    try {
      final response = await _api.searchUsers(
        query: trimmed,
        perPage: 20,
      );

      state = state.copyWith(
        isSearching: false,
        users: response.data,
      );
    } catch (error) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void toggleUser(UserSearchResultModel user) {
    final exists = state.selectedUsers.any((item) => item.id == user.id);

    if (exists) {
      state = state.copyWith(
        selectedUsers: state.selectedUsers
            .where((item) => item.id != user.id)
            .toList(growable: false),
      );
      return;
    }

    state = state.copyWith(
      selectedUsers: [
        ...state.selectedUsers,
        user,
      ],
    );
  }

  Future<int?> createAnnouncement({
    required String title,
  }) async {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Announcement name is required.',
      );
      return null;
    }

    if (state.isCreating) return null;

    state = state.copyWith(
      isCreating: true,
      clearError: true,
    );

    try {
      final conversation = await _api.createAnnouncementConversation(
        title: trimmedTitle,
        memberIds: state.selectedUsers.map((user) => user.id).toList(),
      );

      await _dao.upsertConversation(
        conversation.toLocalCompanion(),
      );

      state = state.copyWith(
        isCreating: false,
      );

      return conversation.id;
    } catch (error) {
      state = state.copyWith(
        isCreating: false,
        errorMessage: _friendlyError(error),
      );

      return null;
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

    return 'Could not create announcement.';
  }
}