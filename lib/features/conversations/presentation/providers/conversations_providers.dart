import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';

final localConversationsProvider =
StreamProvider.autoDispose<List<LocalConversation>>((ref) {
  final dao = ref.watch(chatLocalDaoProvider);

  return dao.watchConversations();
});

//This is the most important part of Phase 10.
//
// The UI watches this provider, and this provider watches local Drift data.