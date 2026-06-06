import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../../core/database/daos/chat_local_dao.dart';
import '../../data/conversation_api.dart';
import '../../data/conversation_details_models.dart';
import '../../data/conversation_mappers.dart';
import 'conversation_details_state.dart';

final conversationDetailsControllerProvider =
AutoDisposeNotifierProviderFamily<ConversationDetailsController,
    ConversationDetailsState, int>(
  ConversationDetailsController.new,
);

class ConversationDetailsController
    extends AutoDisposeFamilyNotifier<ConversationDetailsState, int> {
  late final int _conversationId;
  late final ConversationApi _api;
  late final ChatLocalDao _dao;

  @override
  ConversationDetailsState build(int arg) {
    _conversationId = arg;
    _api = ref.read(conversationApiProvider);
    _dao = ref.read(chatLocalDaoProvider);

    return const ConversationDetailsState.initial();
  }

  Future<void> loadDetails({
    bool refresh = false,
  }) async {
    if (state.isLoading || state.isRefreshing) return;

    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
    );

    try {
      final details = await _api.fetchConversationDetails(
        conversationId: _conversationId,
      );

      await _saveDetails(details);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> addMember({
    required int userId,
  }) async {
    if (state.isAddingMember) return;

    state = state.copyWith(
      isAddingMember: true,
      clearError: true,
    );

    try {
      final participant = await _api.addMember(
        conversationId: _conversationId,
        userId: userId,
      );

      await _saveParticipant(participant);

      state = state.copyWith(
        isAddingMember: false,
      );
    } catch (error) {
      state = state.copyWith(
        isAddingMember: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> removeMember({
    required int userId,
  }) async {
    if (state.removingUserId != null) return;

    state = state.copyWith(
      removingUserId: userId,
      clearError: true,
    );

    try {
      final participant = await _api.removeMember(
        conversationId: _conversationId,
        userId: userId,
      );

      await _saveParticipant(participant);

      final leftAt = participant.leftAt ?? DateTime.now();

      await _dao.markParticipantRemoved(
        conversationId: _conversationId,
        userId: userId,
        leftAt: leftAt,
      );

      state = state.copyWith(
        clearRemovingUserId: true,
      );
    } catch (error) {
      state = state.copyWith(
        clearRemovingUserId: true,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> promoteMember({
    required int userId,
  }) async {
    if (state.promotingUserId != null) return;

    state = state.copyWith(
      promotingUserId: userId,
      clearError: true,
    );

    try {
      final participant = await _api.promoteMember(
        conversationId: _conversationId,
        userId: userId,
      );

      await _saveParticipant(participant);

      state = state.copyWith(
        clearPromotingUserId: true,
      );
    } catch (error) {
      state = state.copyWith(
        clearPromotingUserId: true,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> _saveDetails(ConversationDetailsModel details) async {
    await _dao.upsertConversationDetails(
      conversation: details.toLocalConversationCompanion(),
      users: details.participants
          .map((participant) => participant.toLocalUserCompanion())
          .toList(growable: false),
      participants: details.participants
          .map(
            (participant) => participant.toLocalParticipantCompanion(
          fallbackConversationId: details.id,
        ),
      )
          .toList(growable: false),
    );
  }

  Future<void> _saveParticipant(
      ConversationParticipantModel participant,
      ) async {
    await _dao.upsertUser(
      participant.toLocalUserCompanion(),
    );

    await _dao.upsertParticipant(
      participant.toLocalParticipantCompanion(
        fallbackConversationId: _conversationId,
      ),
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

      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to server.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timeout. Please try again.';
      }
    }

    return 'Could not load conversation details.';
  }
}