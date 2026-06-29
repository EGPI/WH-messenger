import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';

final pushNotificationApiProvider = Provider<PushNotificationApi>((ref) {
  return PushNotificationApi(ref.watch(dioProvider));
});

class PushNotificationApi {
  final Dio _dio;

  const PushNotificationApi(this._dio);

  Future<void> registerDevice({
    required String deviceUuid,
    required String platform,
    required String fcmToken,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    await _dio.post(
      ApiConstants.devices,
      data: {
        'device_uuid': deviceUuid,
        'platform': platform,
        'fcm_token': fcmToken,
        if (deviceName != null && deviceName.isNotEmpty)
          'device_name': deviceName,
        if (appVersion != null && appVersion.isNotEmpty)
          'app_version': appVersion,
        if (osVersion != null && osVersion.isNotEmpty) 'os_version': osVersion,
      },
    );
  }

  Future<void> revokeDevice({required String deviceUuid}) async {
    await _dio.delete(ApiConstants.device(deviceUuid));
  }
}
