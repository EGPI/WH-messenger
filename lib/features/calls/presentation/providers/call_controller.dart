import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../data/call_foreground_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/call_api.dart';
import '../../data/call_debug_log.dart';
import '../../data/call_models.dart';
import '../../data/webrtc_audio_service.dart';
import 'call_state.dart';

final callControllerProvider =
NotifierProvider<CallController, CallState>(CallController.new);

class CallController extends Notifier<CallState> {
  late final CallApi _callApi;
  late final WebRtcAudioService _webRtcAudioService;
  late final CallForegroundService _callForegroundService;

  final List<CallRealtimeEventModel> _pendingIceEvents = [];

  int? _webRtcCallId;
  bool _isCreatingOffer = false;
  bool _isCreatingAnswer = false;

  @override
  CallState build() {
    _callApi = ref.read(callApiProvider);
    _webRtcAudioService = ref.read(webRtcAudioServiceProvider);
    _callForegroundService = ref.read(callForegroundServiceProvider);

    ref.onDispose(() {
      unawaited(_webRtcAudioService.disposeCall());
    });

    return const CallState.initial();
  }

  Future<CallModel?> startAudioCall({
    required int conversationId,
  }) async {
    if (state.hasActiveCall) {
      state = state.copyWith(
        errorMessage: 'You already have an active call.',
      );
      return null;
    }

    ref.read(callDebugLogProvider.notifier).clear();

    _log('starting audio call conversationId=$conversationId');

    state = state.copyWith(
      phase: CallPhase.starting,
      clearError: true,
      clearActiveCall: true,
    );

    try {
      final call = await _callApi.startAudioCall(
        conversationId: conversationId,
      );

      _log('audio call started callId=${call.id}');

      state = state.copyWith(
        phase: CallPhase.outgoingRinging,
        activeCall: call,
      );

      return call;
    } catch (error) {
      _log('ERROR starting audio call: $error');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not start audio call.',
        ),
      );

      return null;
    }
  }

  void receiveIncomingCall(CallModel call) {
    if (state.hasActiveCall) {
      _log(
        'ignored incoming callId=${call.id} because activeCallId=${state.activeCall?.id} phase=${state.phase}',
      );
      return;
    }

    ref.read(callDebugLogProvider.notifier).clear();

    _log('incoming ringing callId=${call.id} from=${call.callerId}');

    state = state.copyWith(
      phase: CallPhase.incomingRinging,
      activeCall: call,
      clearError: true,
    );
  }

  Future<void> acceptActiveCall() async {
    final call = state.activeCall;

    if (call == null || state.phase != CallPhase.incomingRinging) {
      _log(
        'ignored accept because activeCallId=${call?.id} phase=${state.phase}',
      );
      return;
    }

    _log('accepting callId=${call.id}');

    state = state.copyWith(
      phase: CallPhase.starting,
      clearError: true,
    );

    try {
      final acceptedCall = await _callApi.acceptCall(
        callId: call.id,
      );

      _log('call accepted callId=${acceptedCall.id}');

      state = state.copyWith(
        phase: CallPhase.accepted,
        activeCall: acceptedCall,
      );

      await _ensureWebRtcInitialized(acceptedCall);
      await _startForegroundServiceForCall(acceptedCall);
    } catch (error) {
      _log('ERROR accepting call: $error');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not accept call.',
        ),
      );
    }
  }

  Future<void> rejectActiveCall() async {
    final call = state.activeCall;

    if (call == null) {
      _log('ignored reject because active call is null');
      return;
    }

    _log('rejecting callId=${call.id}');

    state = state.copyWith(
      phase: CallPhase.ending,
      clearError: true,
    );

    try {
      final rejectedCall = await _callApi.rejectCall(
        callId: call.id,
      );

      _log('call rejected callId=${rejectedCall.id}');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.ended,
        activeCall: rejectedCall,
      );
    } catch (error) {
      _log('ERROR rejecting call: $error');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not reject call.',
        ),
      );
    }
  }

  Future<void> endActiveCall() async {
    final call = state.activeCall;

    if (call == null) {
      _log('ignored end because active call is null');
      return;
    }

    _log('ending callId=${call.id}');

    state = state.copyWith(
      phase: CallPhase.ending,
      clearError: true,
    );

    try {
      final endedCall = await _callApi.endCall(
        callId: call.id,
      );

      _log('call ended callId=${endedCall.id}');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.ended,
        activeCall: endedCall,
      );
    } catch (error) {
      _log('ERROR ending call: $error');

      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not end call.',
        ),
      );
    }
  }

  void applyRemoteCallUpdate(CallModel call) {
    final currentCall = state.activeCall;

    if (currentCall != null && currentCall.id != call.id) {
      _log(
        'ignored remote call update callId=${call.id} because activeCallId=${currentCall.id}',
      );
      return;
    }

    final nextPhase = _phaseFromCall(call);

    _log(
      'remote call update callId=${call.id} status=${call.status} nextPhase=$nextPhase',
    );

    state = state.copyWith(
      phase: nextPhase,
      activeCall: call,
      clearError: true,
    );

    if (nextPhase == CallPhase.accepted && _currentUserIsCaller(call)) {
      unawaited(_prepareCallerAndSendOffer(call));
      return;
    }

    if (nextPhase == CallPhase.ended || nextPhase == CallPhase.failed) {
      unawaited(_disposeWebRtc());
    }
  }

  Future<void> handleSignalEvent(CallRealtimeEventModel event) async {
    if (!event.isSignalEvent) {
      _log('ignored non-signal event=${event.eventType}');
      return;
    }

    final call = state.activeCall;

    if (call == null || event.callId != call.id) {
      _log(
        'ignored signal event=${event.eventType} eventCallId=${event.callId} activeCallId=${call?.id}',
      );
      return;
    }

    _log(
      'signal received event=${event.eventType} callId=${event.callId} activeCallId=${call.id}',
    );

    switch (event.eventType) {
      case 'call.offer':
        await _handleOffer(event);
        return;

      case 'call.answer':
        await _handleAnswer(event);
        return;

      case 'call.ice_candidate':
        await _handleIceCandidate(event);
        return;
    }
  }

  void clearFinishedCall() {
    if (!state.isFinished) return;

    _log('clearing finished call');

    unawaited(_disposeWebRtc());

    state = const CallState.initial();
  }

  void resetCallState() {
    _log('resetting call state');

    unawaited(_disposeWebRtc());

    state = const CallState.initial();
  }

  Future<void> toggleMuted() async {
    _log('toggle muted');
    await _webRtcAudioService.toggleMuted();
  }
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    _log('set speakerphone enabled=$enabled');

    await _webRtcAudioService.setSpeakerphoneEnabled(enabled);
  }

  Future<void> toggleSpeakerphone() async {
    _log('toggle speakerphone');

    await _webRtcAudioService.toggleSpeakerphone();
  }

  Future<void> _prepareCallerAndSendOffer(CallModel call) async {
    if (_isCreatingOffer) {
      _log('ignored create offer because already creating offer');
      return;
    }

    _isCreatingOffer = true;

    try {
      _log('caller preparing WebRTC callId=${call.id}');

      await _ensureWebRtcInitialized(call);
      await _startForegroundServiceForCall(call);

      final offer = await _webRtcAudioService.createOffer();

      _log(
        'caller sending offer callId=${call.id} type=${offer['type']} sdpLength=${offer['sdp']?.toString().length}',
      );

      await _callApi.sendSignal(
        callId: call.id,
        type: 'offer',
        payload: offer,
      );

      _log('caller offer sent callId=${call.id}');
    } catch (error) {
      _log('ERROR creating/sending offer: $error');

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not create call offer.',
        ),
      );

      await _disposeWebRtc();
    } finally {
      _isCreatingOffer = false;
    }
  }

  Future<void> _handleOffer(CallRealtimeEventModel event) async {
    if (_isCreatingAnswer) {
      _log('ignored offer because already creating answer');
      return;
    }

    final call = state.activeCall;

    if (call == null) {
      _log('ignored offer because active call is null');
      return;
    }

    _isCreatingAnswer = true;

    try {
      _log('callee received offer callId=${call.id}');

      await _ensureWebRtcInitialized(call);

      final signalPayload = event.signalPayload;
      final sdp = signalPayload['sdp']?.toString();
      final type = signalPayload['type']?.toString() ??
          event.signalType ??
          'offer';

      _log('callee offer type=$type sdpLength=${sdp?.length}');

      if (sdp == null || sdp.isEmpty) {
        _log('ERROR callee offer SDP is empty');
        return;
      }

      await _webRtcAudioService.setRemoteDescription(
        type: type,
        sdp: sdp,
      );

      _log('callee set remote offer');

      await _flushPendingIceCandidates();

      final answer = await _webRtcAudioService.createAnswer();

      _log(
        'callee sending answer callId=${call.id} type=${answer['type']} sdpLength=${answer['sdp']?.toString().length}',
      );

      await _callApi.sendSignal(
        callId: call.id,
        type: 'answer',
        payload: answer,
      );

      _log('callee answer sent callId=${call.id}');

      state = state.copyWith(
        phase: CallPhase.accepted,
        activeCall: call,
        clearError: true,
      );
    } catch (error) {
      _log('ERROR handling offer: $error');

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not answer call offer.',
        ),
      );

      await _disposeWebRtc();
    } finally {
      _isCreatingAnswer = false;
    }
  }

  Future<void> _handleAnswer(CallRealtimeEventModel event) async {
    try {
      _log('caller received answer');

      final signalPayload = event.signalPayload;
      final sdp = signalPayload['sdp']?.toString();
      final type = signalPayload['type']?.toString() ??
          event.signalType ??
          'answer';

      _log('caller answer type=$type sdpLength=${sdp?.length}');

      if (sdp == null || sdp.isEmpty) {
        _log('ERROR caller answer SDP is empty');
        return;
      }

      await _webRtcAudioService.setRemoteDescription(
        type: type,
        sdp: sdp,
      );

      _log('caller set remote answer');

      await _flushPendingIceCandidates();
    } catch (error) {
      _log('ERROR handling answer: $error');

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(
          error,
          fallback: 'Could not apply call answer.',
        ),
      );

      await _disposeWebRtc();
    }
  }

  Future<void> _handleIceCandidate(CallRealtimeEventModel event) async {
    _log('received ICE candidate callId=${event.callId}');

    if (!_webRtcAudioService.isInitialized) {
      _log('queue ICE because WebRTC is not initialized');
      _pendingIceEvents.add(event);
      return;
    }

    try {
      await _applyIceCandidate(event);
      _log('ICE candidate applied');
    } catch (error) {
      _log('queue ICE because apply failed: $error');
      _pendingIceEvents.add(event);
    }
  }

  Future<void> _flushPendingIceCandidates() async {
    if (_pendingIceEvents.isEmpty) {
      _log('no pending ICE candidates to flush');
      return;
    }

    final events = List<CallRealtimeEventModel>.from(_pendingIceEvents);
    _pendingIceEvents.clear();

    _log('flushing pending ICE candidates count=${events.length}');

    for (final event in events) {
      try {
        await _applyIceCandidate(event);
        _log('pending ICE candidate applied');
      } catch (error) {
        _log('ignored stale/bad pending ICE candidate: $error');
      }
    }
  }

  Future<void> _applyIceCandidate(CallRealtimeEventModel event) async {
    final signalPayload = event.signalPayload;

    final candidate = signalPayload['candidate']?.toString();

    if (candidate == null || candidate.trim().isEmpty) {
      _log('ignored ICE because candidate is empty');
      return;
    }

    _log(
      'applying ICE candidate sdpMid=${signalPayload['sdpMid']} sdpMLineIndex=${signalPayload['sdpMLineIndex']} candidateLength=${candidate.length}',
    );

    await _webRtcAudioService.addIceCandidate(
      candidate: candidate,
      sdpMid: signalPayload['sdpMid']?.toString(),
      sdpMLineIndex: _parseInt(signalPayload['sdpMLineIndex']),
    );
  }

  Future<void> _ensureWebRtcInitialized(CallModel call) async {
    if (_webRtcAudioService.isInitialized && _webRtcCallId == call.id) {
      _log('WebRTC already initialized for callId=${call.id}');
      return;
    }

    if (_webRtcAudioService.isInitialized && _webRtcCallId != call.id) {
      _log(
        'disposing previous WebRTC callId=$_webRtcCallId before init callId=${call.id}',
      );
      await _disposeWebRtc();
    }

    _webRtcCallId = call.id;

    _log('initializing WebRTC callId=${call.id}');

    await _webRtcAudioService.initialize(
      onIceCandidate: (candidate) {
        _log('sending local ICE candidate callId=${call.id}');

        return _callApi.sendSignal(
          callId: call.id,
          type: 'ice_candidate',
          payload: candidate,
        );
      },
      onConnectionStateChanged: (connectionState) {
        _handlePeerConnectionState(call, connectionState);
      },
    );

    _log('WebRTC initialized callId=${call.id}');
  }

  void _handlePeerConnectionState(
      CallModel call,
      RTCPeerConnectionState connectionState,
      ) {
    _log('peer state callId=${call.id}: $connectionState');

    if (state.activeCall?.id != call.id) return;

    if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
        connectionState == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: 'Call connection failed.',
      );
      return;
    }

    if (connectionState ==
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      state = state.copyWith(
        errorMessage: 'Call connection was interrupted.',
      );
    }
  }

  Future<void> _disposeWebRtc() async {
    _log('disposing WebRTC');

    _pendingIceEvents.clear();
    _webRtcCallId = null;
    _isCreatingOffer = false;
    _isCreatingAnswer = false;

    await _webRtcAudioService.disposeCall();
    await _callForegroundService.stop();
  }

  bool _currentUserIsCaller(CallModel call) {
    final currentUserId = ref.read(
      authControllerProvider.select((state) => state.user?.id),
    );

    return call.isCaller(currentUserId);
  }

  Future<void> _startForegroundServiceForCall(CallModel call) async {
    final currentUserId = ref.read(
      authControllerProvider.select((state) => state.user?.id),
    );

    final peerName = call.otherParticipant(currentUserId)?.displayName ??
        _fallbackPeerName(call, currentUserId);

    await _callForegroundService.startForCall(
      callId: call.id,
      peerName: peerName,
    );
  }

  String _fallbackPeerName(CallModel call, int? currentUserId) {
    final otherUserId = call.callerId == currentUserId
        ? call.calleeId
        : call.callerId;

    if (otherUserId == null) return 'Audio call';

    return 'User $otherUserId';
  }

  CallPhase _phaseFromCall(CallModel call) {
    switch (call.status) {
      case 'ringing':
        return CallPhase.outgoingRinging;

      case 'accepted':
        return CallPhase.accepted;

      case 'ended':
      case 'rejected':
      case 'missed':
      case 'cancelled':
        return CallPhase.ended;

      case 'failed':
        return CallPhase.failed;

      default:
        return CallPhase.idle;
    }
  }

  String _friendlyError(
      Object error, {
        required String fallback,
      }) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
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

    return fallback;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  void _log(String message) {
    ref.read(callDebugLogProvider.notifier).add(
      'CALL CONTROLLER: $message',
    );
  }
}