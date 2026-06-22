import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/call_models.dart';
import 'call_controller.dart';

final lastCallSignalEventProvider =
StateProvider<CallRealtimeEventModel?>((ref) => null);

final callSignalingControllerProvider = Provider<CallSignalingController>((ref) {
  return CallSignalingController(ref);
});

class CallSignalingController {
  final Ref _ref;

  const CallSignalingController(this._ref);

  void handleRealtimeJson(Map<String, dynamic> json) {
    final event = CallRealtimeEventModel.fromJson(json);

    handleRealtimeEvent(event);
  }

  void handleRealtimeEvent(CallRealtimeEventModel event) {
    if (!event.eventType.startsWith('call.')) return;

    switch (event.eventType) {
      case 'call.ringing':
        _handleRinging(event);
        return;

      case 'call.accepted':
      case 'call.rejected':
      case 'call.ended':
      case 'call.cancelled':
      case 'call.missed':
        _handleCallUpdate(event);
        return;

      case 'call.offer':
      case 'call.answer':
      case 'call.ice_candidate':
        _handleSignal(event);
        return;
    }
  }

  void _handleRinging(CallRealtimeEventModel event) {
    final call = event.call;

    if (call == null) return;

    _ref.read(callControllerProvider.notifier).receiveIncomingCall(call);
  }

  void _handleCallUpdate(CallRealtimeEventModel event) {
    final call = event.call;

    if (call == null) return;

    _ref.read(callControllerProvider.notifier).applyRemoteCallUpdate(call);
  }

  void _handleSignal(CallRealtimeEventModel event) {
    final activeCall = _ref.read(callControllerProvider).activeCall;

    if (activeCall != null && event.callId != activeCall.id) {
      return;
    }

    _ref.read(lastCallSignalEventProvider.notifier).state = event;

    unawaited(
      _ref.read(callControllerProvider.notifier).handleSignalEvent(event),
    );
  }
}