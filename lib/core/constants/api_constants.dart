class ApiConstants {
  static const String baseUrl = 'https://wh-egpi.com/messenger-api/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String usersSearch = '/users/search';

  static const String conversations = '/conversations';
  static const String createDirectConversation = '/conversations/direct';
  static const String createGroupConversation = '/conversations/group';
  static const String createAnnouncementConversation =
      '/conversations/announcement';

  static String conversationDetails(int conversationId) {
    return '/conversations/$conversationId/details';
  }

  static String conversationMembers(int conversationId) {
    return '/conversations/$conversationId/members';
  }

  static String conversationMember({
    required int conversationId,
    required int userId,
  }) {
    return '/conversations/$conversationId/members/$userId';
  }

  static String conversationAdmin({
    required int conversationId,
    required int userId,
  }) {
    return '/conversations/$conversationId/admins/$userId';
  }
}