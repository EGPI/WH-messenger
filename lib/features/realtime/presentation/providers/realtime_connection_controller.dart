import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../calls/presentation/providers/call_signaling_controller.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../sync/presentation/providers/chat_sync_controller.dart';
import '../../data/realtime_config.dart';
import '../../data/realtime_event_models.dart';
import 'realtime_connection_state.dart';

final realtimeConnectionControllerProvider =
    NotifierProvider<RealtimeConnectionController, RealtimeConnectionState>(
      RealtimeConnectionController.new,
    );

class RealtimeConnectionController extends Notifier<RealtimeConnectionState> {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  bool _isManuallyDisconnected = false;
  bool _isSubscribed = false;
  bool _isConnecting = false;

  int? _connectedUserId;
  String? _socketId;

  Timer? _reconnectTimer;
  Timer? _pingTimer;

  @override
  RealtimeConnectionState build() {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final user = next.user;

      if (next.status == AuthStatus.authenticated && user != null) {
        connect(userId: user.id);
      } else if (next.status == AuthStatus.unauthenticated) {
        disconnect();
      }
    });

    ref.onDispose(() {
      _cleanup();
    });

    return const RealtimeConnectionState.disconnected();
  }

  Future<void> connect({required int userId}) async {
    if (_isConnecting) return;

    if (_connectedUserId == userId &&
        state.status == RealtimeConnectionStatus.connected &&
        _channel != null) {
      return;
    }

    _isConnecting = true;
    _isManuallyDisconnected = false;
    _connectedUserId = userId;

    state = state.copyWith(
      status: RealtimeConnectionStatus.connecting,
      clearError: true,
    );

    try {
      await _subscription?.cancel();
      await _channel?.sink.close();

      _isSubscribed = false;
      _socketId = null;

      _channel = WebSocketChannel.connect(
        Uri.parse(RealtimeConfig.websocketUrl),
      );

      unawaited(_watchSocketReady(_channel!));

      _subscription = _channel!.stream.listen(
        _handleRawFrame,
        onError: _handleSocketError,
        onDone: _handleSocketDone,
        cancelOnError: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: RealtimeConnectionStatus.error,
        errorMessage: error.toString(),
      );

      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _watchSocketReady(WebSocketChannel channel) async {
    try {
      await channel.ready;
    } catch (error) {
      if (!identical(channel, _channel)) return;

      _handleSocketError(error);
    }
  }

  Future<void> disconnect() async {
    _isManuallyDisconnected = true;

    await _cleanup();

    state = state.copyWith(
      status: RealtimeConnectionStatus.disconnected,
      clearError: true,
    );
  }

  Future<void> _cleanup() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {
      // Ignore close errors.
    }

    _channel = null;
    _socketId = null;
    _isSubscribed = false;
  }

  Future<void> _handleRawFrame(dynamic rawFrame) async {
    if (rawFrame is! String) return;

    final frame = Map<String, dynamic>.from(jsonDecode(rawFrame) as Map);

    final eventName = frame['event']?.toString() ?? '';

    if (eventName == 'pusher:connection_established') {
      await _handleConnectionEstablished(frame);
      return;
    }

    if (eventName == 'pusher:pong') {
      return;
    }

    if (eventName == 'pusher_internal:subscription_succeeded') {
      _isSubscribed = true;

      state = state.copyWith(
        status: RealtimeConnectionStatus.connected,
        clearError: true,
      );

      // Reconnect rule:
      // once the private channel is subscribed, sync missed events.
      await ref.read(chatSyncControllerProvider.notifier).syncNow();
      return;
    }

    if (eventName.startsWith('pusher:')) {
      return;
    }

    if (eventName.startsWith('pusher_internal:')) {
      return;
    }

    if (_isCallFrame(frame)) {
      await _handleCallEvent(frame);
      return;
    }

    await _handleChatEvent(frame);
  }

  Future<void> _handleConnectionEstablished(Map<String, dynamic> frame) async {
    final rawData = frame['data'];

    final Map<String, dynamic> data;

    if (rawData is String) {
      data = Map<String, dynamic>.from(jsonDecode(rawData) as Map);
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else {
      throw const FormatException(
        'Invalid pusher:connection_established data.',
      );
    }

    final socketId = data['socket_id']?.toString();

    if (socketId == null || socketId.isEmpty) {
      throw const FormatException('Missing socket_id from Reverb.');
    }

    _socketId = socketId;

    state = state.copyWith(
      status: RealtimeConnectionStatus.connecting,
      clearError: true,
    );

    _startPingTimer();

    final userId = _connectedUserId;
    if (userId == null) return;

    await _subscribePrivateUserChannel(userId: userId, socketId: socketId);
  }

  Future<void> _subscribePrivateUserChannel({
    required int userId,
    required String socketId,
  }) async {
    final channelName = 'private-user.$userId';

    final auth = await _authorizePrivateChannel(
      socketId: socketId,
      channelName: channelName,
    );

    _sendFrame({
      'event': 'pusher:subscribe',
      'data': {'auth': auth, 'channel': channelName},
    });
  }

  Future<String> _authorizePrivateChannel({
    required String socketId,
    required String channelName,
  }) async {
    final storage = ref.read(authStorageProvider);
    final token = await storage.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token for private channel auth.');
    }

    final dio = ref.read(dioProvider);

    final response = await dio.post(
      RealtimeConfig.authEndpoint,
      data: {'socket_id': socketId, 'channel_name': channelName},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final raw = response.data;

    if (raw is! Map) {
      throw Exception(
        'Invalid broadcasting auth response type: ${raw.runtimeType}',
      );
    }

    final data = Map<String, dynamic>.from(raw);
    final auth = data['auth']?.toString();

    if (auth == null || auth.isEmpty) {
      throw Exception('Missing auth value from broadcasting auth response.');
    }

    return auth;
  }

  String _normalizeEventName(String value) {
    final trimmed = value.trim();

    if (trimmed.startsWith('.')) {
      return trimmed.substring(1);
    }

    return trimmed;
  }

  bool _isCallEventName(String eventName) {
    return _normalizeEventName(eventName).startsWith('call.');
  }

  bool _isCallFrame(Map<String, dynamic> frame) {
    final frameEventName = frame['event']?.toString() ?? '';

    if (_isCallEventName(frameEventName)) {
      return true;
    }

    try {
      final data = _decodeFrameData(frame);
      final payloadEventType = data['event_type']?.toString() ?? '';

      return _isCallEventName(payloadEventType);
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleCallEvent(Map<String, dynamic> frame) async {
    try {
      final data = _decodeFrameData(frame);

      final frameEventName = frame['event']?.toString() ?? '';
      final payloadEventType = data['event_type']?.toString();

      final normalizedEventName = _normalizeEventName(
        payloadEventType != null && payloadEventType.trim().isNotEmpty
            ? payloadEventType
            : frameEventName,
      );

      final eventPayload = <String, dynamic>{
        ...data,
        'event_type': normalizedEventName,
      };

      ref
          .read(callSignalingControllerProvider)
          .handleRealtimeJson(eventPayload);
    } catch (error) {
      state = state.copyWith(
        status: RealtimeConnectionStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Map<String, dynamic> _decodeFrameData(Map<String, dynamic> frame) {
    final rawData = frame['data'];

    if (rawData is String) {
      final decoded = jsonDecode(rawData);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }

    return <String, dynamic>{};
  }

  Future<void> _handleChatEvent(Map<String, dynamic> frame) async {
    try {
      final envelope = RealtimeEventEnvelope.fromFrame(frame);

      await ref
          .read(chatSyncControllerProvider.notifier)
          .applyRealtimeEvent(envelope.syncEvent);
    } catch (error) {
      state = state.copyWith(
        status: RealtimeConnectionStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  void _handleSocketError(Object error) {
    if (_isManuallyDisconnected) return;

    state = state.copyWith(
      status: RealtimeConnectionStatus.error,
      errorMessage: error.toString(),
    );

    _scheduleReconnect();
  }

  void _handleSocketDone() {
    if (_isManuallyDisconnected) return;

    state = state.copyWith(status: RealtimeConnectionStatus.reconnecting);

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isManuallyDisconnected) return;

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      final userId = _connectedUserId;

      if (userId == null) return;

      connect(userId: userId);
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _sendFrame({'event': 'pusher:ping', 'data': {}});
    });
  }

  void _sendFrame(Map<String, dynamic> frame) {
    final channel = _channel;

    if (channel == null) return;

    channel.sink.add(jsonEncode(frame));
  }
}
