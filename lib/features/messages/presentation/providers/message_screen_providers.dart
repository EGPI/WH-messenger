import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';

final localMessagesProvider =
StreamProvider.family<List<LocalMessage>, int>((ref, conversationId) {
  final dao = ref.watch(chatLocalDaoProvider);
  return dao.watchMessages(conversationId);
});

final openConversationIdProvider = StateProvider<int?>((ref) {
  return null;
});

final localConversationProvider =
StreamProvider.family<LocalConversation?, int>((ref, conversationId) {
  final database = ref.watch(appDatabaseProvider);

  return (database.select(database.localConversations)
    ..where((t) => t.id.equals(conversationId)))
      .watchSingleOrNull();
});