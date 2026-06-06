import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../../core/database/daos/chat_local_dao.dart';
import '../../../../core/database/app_database.dart';

final localConversationParticipantsProvider = StreamProvider.family<
    List<LocalConversationParticipantWithUser>, int>((ref, conversationId) {
  final dao = ref.watch(chatLocalDaoProvider);

  return dao.watchConversationParticipantsWithUsers(conversationId);
});

final conversationDetailsLocalConversationProvider =
StreamProvider.family<LocalConversation?, int>((ref, conversationId) {
  final database = ref.watch(appDatabaseProvider);

  return (database.select(database.localConversations)
    ..where((t) => t.id.equals(conversationId)))
      .watchSingleOrNull();
});