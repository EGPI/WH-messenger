class ConversationDetailsState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isAddingMember;
  final int? removingUserId;
  final int? promotingUserId;
  final String? errorMessage;

  const ConversationDetailsState({
    required this.isLoading,
    required this.isRefreshing,
    required this.isAddingMember,
    required this.removingUserId,
    required this.promotingUserId,
    required this.errorMessage,
  });

  const ConversationDetailsState.initial()
      : isLoading = false,
        isRefreshing = false,
        isAddingMember = false,
        removingUserId = null,
        promotingUserId = null,
        errorMessage = null;

  ConversationDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isAddingMember,
    int? removingUserId,
    bool clearRemovingUserId = false,
    int? promotingUserId,
    bool clearPromotingUserId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isAddingMember: isAddingMember ?? this.isAddingMember,
      removingUserId:
      clearRemovingUserId ? null : removingUserId ?? this.removingUserId,
      promotingUserId:
      clearPromotingUserId ? null : promotingUserId ?? this.promotingUserId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}