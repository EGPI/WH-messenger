class MessageScreenState {
  final bool isInitialSyncing;
  final bool isLoadingOlder;
  final bool hasMoreOlder;
  final String? errorMessage;

  const MessageScreenState({
    required this.isInitialSyncing,
    required this.isLoadingOlder,
    required this.hasMoreOlder,
    required this.errorMessage,
  });

  const MessageScreenState.initial()
      : isInitialSyncing = false,
        isLoadingOlder = false,
        hasMoreOlder = true,
        errorMessage = null;

  MessageScreenState copyWith({
    bool? isInitialSyncing,
    bool? isLoadingOlder,
    bool? hasMoreOlder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageScreenState(
      isInitialSyncing: isInitialSyncing ?? this.isInitialSyncing,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}