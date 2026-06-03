import '../../data/user_search_models.dart';

class NewAnnouncementChatState {
  final bool isSearching;
  final bool isCreating;
  final List<UserSearchResultModel> users;
  final List<UserSearchResultModel> selectedUsers;
  final String? errorMessage;

  const NewAnnouncementChatState({
    required this.isSearching,
    required this.isCreating,
    required this.users,
    required this.selectedUsers,
    required this.errorMessage,
  });

  const NewAnnouncementChatState.initial()
      : isSearching = false,
        isCreating = false,
        users = const [],
        selectedUsers = const [],
        errorMessage = null;

  NewAnnouncementChatState copyWith({
    bool? isSearching,
    bool? isCreating,
    List<UserSearchResultModel>? users,
    List<UserSearchResultModel>? selectedUsers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewAnnouncementChatState(
      isSearching: isSearching ?? this.isSearching,
      isCreating: isCreating ?? this.isCreating,
      users: users ?? this.users,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}