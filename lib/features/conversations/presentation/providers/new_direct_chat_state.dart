import '../../data/user_search_models.dart';

class NewDirectChatState {
  final bool isSearching;
  final bool isCreating;
  final List<UserSearchResultModel> users;
  final String? errorMessage;

  const NewDirectChatState({
    required this.isSearching,
    required this.isCreating,
    required this.users,
    required this.errorMessage,
  });

  const NewDirectChatState.initial()
      : isSearching = false,
        isCreating = false,
        users = const [],
        errorMessage = null;

  NewDirectChatState copyWith({
    bool? isSearching,
    bool? isCreating,
    List<UserSearchResultModel>? users,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewDirectChatState(
      isSearching: isSearching ?? this.isSearching,
      isCreating: isCreating ?? this.isCreating,
      users: users ?? this.users,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}