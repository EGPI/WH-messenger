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
  final bool isScreenMinimized;
  final bool isMuted;
  final bool isSpeakerphoneEnabled;

  const CallState({
    required this.phase,
    required this.activeCall,
    required this.errorMessage,
    required this.isScreenMinimized,
    required this.isMuted,
    required this.isSpeakerphoneEnabled,
  });

  const CallState.initial()
    : phase = CallPhase.idle,
      activeCall = null,
      errorMessage = null,
      isScreenMinimized = false,
      isMuted = false,
      isSpeakerphoneEnabled = false;

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
    bool? isScreenMinimized,
    bool? isMuted,
    bool? isSpeakerphoneEnabled,
  }) {
    return CallState(
      phase: phase ?? this.phase,
      activeCall: clearActiveCall ? null : activeCall ?? this.activeCall,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isScreenMinimized: isScreenMinimized ?? this.isScreenMinimized,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerphoneEnabled:
          isSpeakerphoneEnabled ?? this.isSpeakerphoneEnabled,
    );
  }
}
