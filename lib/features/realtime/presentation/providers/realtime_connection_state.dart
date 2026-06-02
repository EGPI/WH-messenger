enum RealtimeConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class RealtimeConnectionState {
  final RealtimeConnectionStatus status;
  final String? errorMessage;

  const RealtimeConnectionState({
    required this.status,
    required this.errorMessage,
  });

  const RealtimeConnectionState.disconnected()
      : status = RealtimeConnectionStatus.disconnected,
        errorMessage = null;

  RealtimeConnectionState copyWith({
    RealtimeConnectionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RealtimeConnectionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}