class ApiConstants {
  static const String baseUrl = 'http://192.168.1.5:8000/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String usersSearch = '/users/search';
  static const String createDirectConversation = '/conversations/direct';
  static const String createGroupConversation = '/conversations/group';
  static const String createAnnouncementConversation =
      '/conversations/announcement';

  static const String conversations = '/conversations';

}