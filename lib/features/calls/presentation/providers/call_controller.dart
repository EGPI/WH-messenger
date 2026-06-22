import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../data/call_foreground_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/call_api.dart';
import '../../data/call_models.dart';
import '../../data/webrtc_audio_service.dart';
import 'call_state.dart';

final callControllerProvider = NotifierProvider<CallController, CallState>(
  CallController.new,
);

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
      unawaited(_endCallIfStillActive(state.activeCall));
      unawaited(_webRtcAudioService.disposeCall());
    });

    return const CallState.initial();
  }

  Future<CallModel?> startAudioCall({required int conversationId}) async {
    if (state.hasActiveCall) {
      state = state.copyWith(errorMessage: 'You already have an active call.');
      return null;
    }

    state = state.copyWith(
      phase: CallPhase.starting,
      clearError: true,
      clearActiveCall: true,
    );

    try {
      final call = await _callApi.startAudioCall(
        conversationId: conversationId,
      );

      state = state.copyWith(
        phase: CallPhase.outgoingRinging,
        activeCall: call,
      );

      return call;
    } catch (error) {
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
      return;
    }

    state = state.copyWith(
      phase: CallPhase.incomingRinging,
      activeCall: call,
      clearError: true,
    );
  }

  Future<void> acceptActiveCall() async {
    final call = state.activeCall;

    if (call == null || state.phase != CallPhase.incomingRinging) {
      return;
    }

    state = state.copyWith(phase: CallPhase.starting, clearError: true);

    try {
      final acceptedCall = await _callApi.acceptCall(callId: call.id);

      state = state.copyWith(
        phase: CallPhase.accepted,
        activeCall: acceptedCall,
      );

      await _ensureWebRtcInitialized(acceptedCall);
      await _startForegroundServiceForCall(acceptedCall);
    } catch (error) {
      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(error, fallback: 'Could not accept call.'),
      );
    }
  }

  Future<void> rejectActiveCall() async {
    final call = state.activeCall;

    if (call == null) {
      return;
    }

    state = state.copyWith(phase: CallPhase.ending, clearError: true);

    try {
      final rejectedCall = await _callApi.rejectCall(callId: call.id);
      await _disposeWebRtc();

      state = state.copyWith(phase: CallPhase.ended, activeCall: rejectedCall);
    } catch (error) {
      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(error, fallback: 'Could not reject call.'),
      );
    }
  }

  Future<void> endActiveCall() async {
    final call = state.activeCall;

    if (call == null) {
      return;
    }

    state = state.copyWith(phase: CallPhase.ending, clearError: true);

    try {
      final endedCall = await _callApi.endCall(callId: call.id);

      await _disposeWebRtc();

      state = state.copyWith(phase: CallPhase.ended, activeCall: endedCall);
    } catch (error) {
      await _disposeWebRtc();

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: _friendlyError(error, fallback: 'Could not end call.'),
      );
    }
  }

  void applyRemoteCallUpdate(CallModel call) {
    final currentCall = state.activeCall;

    if (currentCall != null && currentCall.id != call.id) {
      return;
    }

    final nextPhase = _phaseFromCall(call);

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
      return;
    }

    final call = state.activeCall;

    if (call == null || event.callId != call.id) {
      return;
    }

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

    unawaited(_endCallIfStillActive(state.activeCall));
    unawaited(_disposeWebRtc());

    state = const CallState.initial();
  }

  void resetCallState() {
    unawaited(_endCallIfStillActive(state.activeCall));
    unawaited(_disposeWebRtc());

    state = const CallState.initial();
  }

  Future<void> dismissCallScreen() async {
    final call = state.activeCall;

    await _endCallIfStillActive(call);
    await _disposeWebRtc();

    state = const CallState.initial();
  }

  Future<void> toggleMuted() async {
    await _webRtcAudioService.toggleMuted();
  }

  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    await _webRtcAudioService.setSpeakerphoneEnabled(enabled);
  }

  Future<void> toggleSpeakerphone() async {
    await _webRtcAudioService.toggleSpeakerphone();
  }

  Future<void> _prepareCallerAndSendOffer(CallModel call) async {
    if (_isCreatingOffer) {
      return;
    }

    _isCreatingOffer = true;

    try {
      await _ensureWebRtcInitialized(call);
      await _startForegroundServiceForCall(call);

      final offer = await _webRtcAudioService.createOffer();

      await _callApi.sendSignal(callId: call.id, type: 'offer', payload: offer);
    } catch (error) {
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
      return;
    }

    final call = state.activeCall;

    if (call == null) {
      return;
    }

    _isCreatingAnswer = true;

    try {
      await _ensureWebRtcInitialized(call);

      final signalPayload = event.signalPayload;
      final sdp = signalPayload['sdp']?.toString();
      final type =
          signalPayload['type']?.toString() ?? event.signalType ?? 'offer';

      if (sdp == null || sdp.isEmpty) {
        return;
      }

      await _webRtcAudioService.setRemoteDescription(type: type, sdp: sdp);

      await _flushPendingIceCandidates();

      final answer = await _webRtcAudioService.createAnswer();

      await _callApi.sendSignal(
        callId: call.id,
        type: 'answer',
        payload: answer,
      );

      state = state.copyWith(
        phase: CallPhase.accepted,
        activeCall: call,
        clearError: true,
      );
    } catch (error) {
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
      final signalPayload = event.signalPayload;
      final sdp = signalPayload['sdp']?.toString();
      final type =
          signalPayload['type']?.toString() ?? event.signalType ?? 'answer';

      if (sdp == null || sdp.isEmpty) {
        return;
      }

      await _webRtcAudioService.setRemoteDescription(type: type, sdp: sdp);

      await _flushPendingIceCandidates();
    } catch (error) {
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
    if (!_webRtcAudioService.isInitialized) {
      _pendingIceEvents.add(event);
      return;
    }

    try {
      await _applyIceCandidate(event);
    } catch (error) {
      _pendingIceEvents.add(event);
    }
  }

  Future<void> _flushPendingIceCandidates() async {
    if (_pendingIceEvents.isEmpty) {
      return;
    }

    final events = List<CallRealtimeEventModel>.from(_pendingIceEvents);
    _pendingIceEvents.clear();

    for (final event in events) {
      try {
        await _applyIceCandidate(event);
      } catch (_) {
        // Ignore stale or invalid pending ICE candidates.
      }
    }
  }

  Future<void> _applyIceCandidate(CallRealtimeEventModel event) async {
    final signalPayload = event.signalPayload;

    final candidate = signalPayload['candidate']?.toString();

    if (candidate == null || candidate.trim().isEmpty) {
      return;
    }

    await _webRtcAudioService.addIceCandidate(
      candidate: candidate,
      sdpMid: signalPayload['sdpMid']?.toString(),
      sdpMLineIndex: _parseInt(signalPayload['sdpMLineIndex']),
    );
  }

  Future<void> _ensureWebRtcInitialized(CallModel call) async {
    if (_webRtcAudioService.isInitialized && _webRtcCallId == call.id) {
      return;
    }

    if (_webRtcAudioService.isInitialized && _webRtcCallId != call.id) {
      await _disposeWebRtc();
    }

    _webRtcCallId = call.id;

    await _webRtcAudioService.initialize(
      onIceCandidate: (candidate) {
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
  }

  void _handlePeerConnectionState(
      CallModel call,
      RTCPeerConnectionState connectionState,
      ) {
    if (state.activeCall?.id != call.id) return;

    if (connectionState ==
        RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
        connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
      if (state.phase == CallPhase.accepted ||
          state.activeCall?.isAccepted == true) {
        state = state.copyWith(
          phase: CallPhase.accepted,
          errorMessage: 'Call connection needs attention.',
        );
        return;
      }

      state = state.copyWith(
        phase: CallPhase.failed,
        errorMessage: 'Call connection failed.',
      );
      return;
    }

    if (connectionState ==
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      state = state.copyWith(errorMessage: 'Call connection was interrupted.');
    }
  }

  Future<void> _endCallIfStillActive(CallModel? call) async {
    if (call == null || call.isFinished) return;

    try {
      await _callApi.endCall(callId: call.id);
    } catch (_) {
      // Ignore cleanup failures.
    }
  }

  Future<void> _disposeWebRtc() async {
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

    final peerName =
        call.otherParticipant(currentUserId)?.displayName ??
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

  String _friendlyError(Object error, {required String fallback}) {
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
}