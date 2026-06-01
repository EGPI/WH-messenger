class ConversationsSyncState {
  //This state is only for sync/loading/error. It is not the conversation list data.
  //
  // The actual conversation list data comes from Drift
  final bool isSyncing;
  final String? errorMessage;
  final DateTime? lastSyncedAt;

  const ConversationsSyncState({
    required this.isSyncing,
    required this.errorMessage,
    required this.lastSyncedAt,
  });

  const ConversationsSyncState.initial()
      : isSyncing = false,
        errorMessage = null,
        lastSyncedAt = null;

  ConversationsSyncState copyWith({
    bool? isSyncing,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastSyncedAt,
  }) {
    return ConversationsSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}