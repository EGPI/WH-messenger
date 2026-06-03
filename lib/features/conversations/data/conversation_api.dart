import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'conversation_models.dart';
import 'user_search_models.dart';

class ConversationApi {
  final Dio _dio;

  const ConversationApi(this._dio);

  Future<ConversationListResponse> getConversations({
    int perPage = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.conversations,
      queryParameters: {
        'per_page': perPage,
      },
    );

    return ConversationListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<UserSearchResponse> searchUsers({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.usersSearch,
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
    );

    return UserSearchResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ConversationSummaryModel> createGroupConversation({
    required String title,
    required List<int> memberIds,
  }) async {
    final response = await _dio.post(
      ApiConstants.createGroupConversation,
      data: {
        'title': title,
        'member_ids': memberIds,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>;

    return ConversationSummaryModel.fromJson(data);
  }

  Future<ConversationSummaryModel> createAnnouncementConversation({
    required String title,
    required List<int> memberIds,
  }) async {
    final response = await _dio.post(
      ApiConstants.createAnnouncementConversation,
      data: {
        'title': title,
        'member_ids': memberIds,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>;

    return ConversationSummaryModel.fromJson(data);
  }

  Future<ConversationSummaryModel> createDirectConversation({
    required int userId,
  }) async {
    final response = await _dio.post(
      ApiConstants.createDirectConversation,
      data: {
        'user_id': userId,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>;

    return ConversationSummaryModel.fromJson(data);
  }
}

final conversationApiProvider = Provider<ConversationApi>((ref) {
  return ConversationApi(ref.watch(dioProvider));
});