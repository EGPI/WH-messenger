import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'call_models.dart';

final callApiProvider = Provider<CallApi>((ref) {
  final dio = ref.watch(dioProvider);

  return CallApi(dio);
});

class CallApi {
  final Dio _dio;

  const CallApi(this._dio);

  Future<CallModel> startAudioCall({
    required int conversationId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.startAudioCall(conversationId),
      data: const <String, dynamic>{},
    );

    final body = response.data ?? <String, dynamic>{};

    return CallResponseModel.fromJson(body).data;
  }

  Future<CallModel> acceptCall({
    required int callId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.acceptCall(callId),
      data: const <String, dynamic>{},
    );

    final body = response.data ?? <String, dynamic>{};

    return CallResponseModel.fromJson(body).data;
  }

  Future<CallModel> rejectCall({
    required int callId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.rejectCall(callId),
      data: const <String, dynamic>{},
    );

    final body = response.data ?? <String, dynamic>{};

    return CallResponseModel.fromJson(body).data;
  }

  Future<CallModel> endCall({
    required int callId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.endCall(callId),
      data: const <String, dynamic>{},
    );

    final body = response.data ?? <String, dynamic>{};

    return CallResponseModel.fromJson(body).data;
  }

  Future<void> sendSignal({
    required int callId,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final request = CallSignalRequestModel(
      type: type,
      payload: payload,
    );

    await _dio.post<Map<String, dynamic>>(
      ApiConstants.signalCall(callId),
      data: request.toJson(),
    );
  }

  Future<CallModel> fetchCall({
    required int callId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.callDetails(callId),
    );

    final body = response.data ?? <String, dynamic>{};

    return CallDetailsResponseModel.fromJson(body).data;
  }
}