class MessageScreenState {
  final bool isInitialSyncing;
  final bool isLoadingOlder;
  final bool hasMoreOlder;
  final bool isSending;
  final String? errorMessage;

  const MessageScreenState({
    required this.isInitialSyncing,
    required this.isLoadingOlder,
    required this.hasMoreOlder,
    required this.isSending,
    required this.errorMessage,
  });

  const MessageScreenState.initial()
      : isInitialSyncing = false,
        isLoadingOlder = false,
        hasMoreOlder = true,
        isSending = false,
        errorMessage = null;

  MessageScreenState copyWith({
    bool? isInitialSyncing,
    bool? isLoadingOlder,
    bool? hasMoreOlder,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageScreenState(
      isInitialSyncing: isInitialSyncing ?? this.isInitialSyncing,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}