import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'conversation_models.dart';

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
}

final conversationApiProvider = Provider<ConversationApi>((ref) {
  return ConversationApi(ref.watch(dioProvider));
});