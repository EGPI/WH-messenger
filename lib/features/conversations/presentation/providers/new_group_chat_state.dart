import '../../data/user_search_models.dart';

class NewGroupChatState {
  final bool isSearching;
  final bool isCreating;
  final List<UserSearchResultModel> users;
  final List<UserSearchResultModel> selectedUsers;
  final String? errorMessage;

  const NewGroupChatState({
    required this.isSearching,
    required this.isCreating,
    required this.users,
    required this.selectedUsers,
    required this.errorMessage,
  });

  const NewGroupChatState.initial()
      : isSearching = false,
        isCreating = false,
        users = const [],
        selectedUsers = const [],
        errorMessage = null;

  NewGroupChatState copyWith({
    bool? isSearching,
    bool? isCreating,
    List<UserSearchResultModel>? users,
    List<UserSearchResultModel>? selectedUsers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewGroupChatState(
      isSearching: isSearching ?? this.isSearching,
      isCreating: isCreating ?? this.isCreating,
      users: users ?? this.users,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}