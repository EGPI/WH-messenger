import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'message_models.dart';

final messageApiProvider = Provider<MessageApi>((ref) {
  return MessageApi(ref.watch(dioProvider));
});

class MessageApi {
  final Dio _dio;

  const MessageApi(this._dio);

  Future<MessageHistoryResponse> fetchMessages({
    required int conversationId,
    int? beforeMessageId,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        if (beforeMessageId != null) 'before_message_id': beforeMessageId,
        'limit': limit,
      },
    );

    debugPrint('MessageApi raw response: ${response.data}');

    final raw = response.data;

    if (raw is! Map) {
      throw Exception(
        'Invalid message history response type: ${raw.runtimeType}',
      );
    }

    final data = Map<String, dynamic>.from(raw);

    return MessageHistoryResponse.fromJson(data);
  }

  Future<void> markConversationRead({
    required int conversationId,
  }) async {
    await _dio.post(
      '/conversations/$conversationId/read',
    );
  }
}