class OutboxRetryState {
  final bool isFlushing;
  final int lastFlushedCount;
  final String? errorMessage;

  const OutboxRetryState({
    required this.isFlushing,
    required this.lastFlushedCount,
    required this.errorMessage,
  });

  const OutboxRetryState.initial()
      : isFlushing = false,
        lastFlushedCount = 0,
        errorMessage = null;

  OutboxRetryState copyWith({
    bool? isFlushing,
    int? lastFlushedCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OutboxRetryState(
      isFlushing: isFlushing ?? this.isFlushing,
      lastFlushedCount: lastFlushedCount ?? this.lastFlushedCount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}