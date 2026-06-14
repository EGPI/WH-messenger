import '../../data/call_models.dart';

enum CallPhase {
  idle,
  starting,
  outgoingRinging,
  incomingRinging,
  accepted,
  ending,
  ended,
  failed,
}

class CallState {
  final CallPhase phase;
  final CallModel? activeCall;
  final String? errorMessage;

  const CallState({
    required this.phase,
    required this.activeCall,
    required this.errorMessage,
  });

  const CallState.initial()
      : phase = CallPhase.idle,
        activeCall = null,
        errorMessage = null;

  bool get hasActiveCall {
    if (activeCall == null) return false;

    return phase == CallPhase.starting ||
        phase == CallPhase.outgoingRinging ||
        phase == CallPhase.incomingRinging ||
        phase == CallPhase.accepted ||
        phase == CallPhase.ending;
  }

  bool get isBusy {
    return phase == CallPhase.starting || phase == CallPhase.ending;
  }

  bool get isIncoming {
    return phase == CallPhase.incomingRinging;
  }

  bool get isOutgoing {
    return phase == CallPhase.outgoingRinging;
  }

  bool get isFinished {
    return phase == CallPhase.ended || phase == CallPhase.failed;
  }

  CallState copyWith({
    CallPhase? phase,
    CallModel? activeCall,
    bool clearActiveCall = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CallState(
      phase: phase ?? this.phase,
      activeCall: clearActiveCall ? null : activeCall ?? this.activeCall,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}