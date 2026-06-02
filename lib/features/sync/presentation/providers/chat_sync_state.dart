class ChatSyncState {
  final bool isSyncing;
  final int lastAppliedEventId;
  final String? errorMessage;

  const ChatSyncState({
    required this.isSyncing,
    required this.lastAppliedEventId,
    required this.errorMessage,
  });

  const ChatSyncState.initial()
      : isSyncing = false,
        lastAppliedEventId = 0,
        errorMessage = null;

  ChatSyncState copyWith({
    bool? isSyncing,
    int? lastAppliedEventId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastAppliedEventId: lastAppliedEventId ?? this.lastAppliedEventId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}