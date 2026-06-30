import 'dart:async';

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'push_notification_api.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    api: ref.watch(pushNotificationApiProvider),
    deviceInfo: DeviceInfoPlugin(),
  );

  ref.onDispose(() {
    unawaited(service.dispose());
  });

  return service;
});

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.initializeFirebase();
}

class PushNotificationService {
  PushNotificationService({
    required PushNotificationApi api,
    required DeviceInfoPlugin deviceInfo,
  }) : _api = api,
       _deviceInfo = deviceInfo;

  static const _deviceUuidKey = 'push_device_uuid';

  static bool _firebaseAvailable = false;

  final PushNotificationApi _api;
  final DeviceInfoPlugin _deviceInfo;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  bool _started = false;
  Future<bool>? _registrationInFlight;
  Timer? _registrationRetryTimer;
  int _registrationRetryAttempt = 0;

  static bool get isFirebaseAvailable => _firebaseAvailable;

  static Future<void> initializeFirebase() async {
    if (_firebaseAvailable) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _firebaseAvailable = true;
    } catch (error) {
      _firebaseAvailable = false;
      debugPrint('Push notifications disabled: $error');
    }
  }

  Future<void> start() async {
    if (!_firebaseAvailable) {
      await initializeFirebase();
    }

    if (!_firebaseAvailable) return;

    if (_started) {
      await registerCurrentDevice();
      return;
    }

    _started = true;

    try {
      await _requestPermission();

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: true,
            sound: false,
          );

      await registerCurrentDevice();

      _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
          .listen((token) => unawaited(_registerRefreshedToken(token)));

      _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      _messageOpenedSubscription ??= FirebaseMessaging.onMessageOpenedApp
          .listen(_handleOpenedMessage);

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        _handleOpenedMessage(initialMessage);
      }
    } catch (error) {
      debugPrint('Could not start push notifications: $error');
    }
  }

  Future<void> stop() async {
    _started = false;
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
    _messageOpenedSubscription = null;
    _registrationRetryTimer?.cancel();
    _registrationRetryTimer = null;
    _registrationRetryAttempt = 0;
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> registerCurrentDevice() async {
    if (!_firebaseAvailable) return;

    if (_registrationInFlight != null) {
      await _registrationInFlight;
      return;
    }

    final registration = _registerCurrentDevice();
    _registrationInFlight = registration;

    try {
      final registered = await registration;
      if (registered) {
        _clearRegistrationRetry();
      } else {
        _scheduleRegistrationRetry();
      }
    } finally {
      _registrationInFlight = null;
    }
  }

  Future<bool> _registerCurrentDevice() async {
    try {
      await _waitForApnsTokenIfNeeded();

      final token = await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('Push token is empty; device was not registered.');
        return false;
      }

      await _registerToken(token);
      return true;
    } catch (error) {
      debugPrint('Could not register push token: ${_describeError(error)}');
      return false;
    }
  }

  Future<void> revokeCurrentDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceUuid = prefs.getString(_deviceUuidKey);

      if (deviceUuid == null || deviceUuid.isEmpty) {
        return;
      }

      await _api.revokeDevice(deviceUuid: deviceUuid);
    } catch (error) {
      debugPrint('Could not revoke push device: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    final device = await _deviceMetadata();

    await _api.registerDevice(
      deviceUuid: device.deviceUuid,
      platform: device.platform,
      fcmToken: token,
      deviceName: device.deviceName,
      appVersion: device.appVersion,
      osVersion: device.osVersion,
    );

    debugPrint(
      'Push device registered: ${device.platform} ${device.deviceUuid}',
    );
  }

  Future<void> _registerRefreshedToken(String token) async {
    try {
      await _registerToken(token);
      _clearRegistrationRetry();
    } catch (error) {
      debugPrint(
        'Could not register refreshed push token: ${_describeError(error)}',
      );
      _scheduleRegistrationRetry();
    }
  }

  void _scheduleRegistrationRetry() {
    if (!_started || !_firebaseAvailable || _registrationRetryTimer != null) {
      return;
    }

    if (_registrationRetryAttempt >= 6) {
      debugPrint('Push device registration retry limit reached.');
      return;
    }

    final delay = Duration(seconds: 5 * (1 << _registrationRetryAttempt));
    _registrationRetryAttempt += 1;

    debugPrint('Retrying push device registration in ${delay.inSeconds}s.');
    _registrationRetryTimer = Timer(delay, () {
      _registrationRetryTimer = null;
      unawaited(registerCurrentDevice());
    });
  }

  void _clearRegistrationRetry() {
    _registrationRetryTimer?.cancel();
    _registrationRetryTimer = null;
    _registrationRetryAttempt = 0;
  }

  Future<void> _requestPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<_DeviceMetadata> _deviceMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceUuid = prefs.getString(_deviceUuidKey);
    final appVersion = await _appVersion();

    if (deviceUuid == null || deviceUuid.isEmpty) {
      deviceUuid = const Uuid().v4();
      await prefs.setString(_deviceUuidKey, deviceUuid);
    }

    if (kIsWeb) {
      final info = await _deviceInfo.webBrowserInfo;
      return _DeviceMetadata(
        deviceUuid: deviceUuid,
        platform: 'web',
        deviceName: info.browserName.name,
        appVersion: appVersion,
        osVersion: info.platform,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _deviceInfo.androidInfo;
        return _DeviceMetadata(
          deviceUuid: deviceUuid,
          platform: 'android',
          deviceName: '${info.manufacturer} ${info.model}'.trim(),
          appVersion: appVersion,
          osVersion: 'Android ${info.version.release}',
        );
      case TargetPlatform.iOS:
        final info = await _deviceInfo.iosInfo;
        return _DeviceMetadata(
          deviceUuid: deviceUuid,
          platform: 'ios',
          deviceName: info.name,
          appVersion: appVersion,
          osVersion: '${info.systemName} ${info.systemVersion}',
        );
      default:
        return _DeviceMetadata(
          deviceUuid: deviceUuid,
          platform: 'web',
          deviceName: defaultTargetPlatform.name,
          appVersion: appVersion,
        );
    }
  }

  Future<void> _waitForApnsTokenIfNeeded() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    for (var attempt = 0; attempt < 5; attempt += 1) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) return;

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  Future<String?> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.buildNumber.isEmpty) return info.version;
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return null;
    }
  }

  String _describeError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      return [
        if (statusCode != null) 'HTTP $statusCode',
        if (data != null) '$data',
        if (error.message != null) error.message,
      ].join(' - ');
    }

    return error.toString();
  }

  void _handleForegroundMessage(RemoteMessage message) {}

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint('Push notification opened: ${message.data}');
  }
}

class _DeviceMetadata {
  final String deviceUuid;
  final String platform;
  final String? deviceName;
  final String? appVersion;
  final String? osVersion;

  const _DeviceMetadata({
    required this.deviceUuid,
    required this.platform,
    this.deviceName,
    this.appVersion,
    this.osVersion,
  });
}