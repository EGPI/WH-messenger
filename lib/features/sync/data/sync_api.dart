import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'sync_models.dart';

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.watch(dioProvider));
});

class SyncApi {
  final Dio _dio;

  const SyncApi(this._dio);

  Future<SyncResponse> getSyncEvents({
    required int afterEventId,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      '/sync',
      queryParameters: {
        'after_event_id': afterEventId,
        'limit': limit,
      },
    );

    final raw = response.data;

    if (raw is! Map) {
      throw Exception('Invalid sync response type: ${raw.runtimeType}');
    }

    return SyncResponse.fromJson(
      Map<String, dynamic>.from(raw),
    );
  }
}