import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'conversation_models.dart';

extension ConversationSummaryModelMapper on ConversationSummaryModel {
  LocalConversationsCompanion toLocalCompanion() {
    return LocalConversationsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      lastMessagePreview: Value(lastMessagePreview),
      lastMessageSenderId: Value(lastMessageSenderId),
      lastMessageAt: Value(lastMessageAt),
      unreadCount: Value(unreadCount),
      myRole: Value(myRole),
      updatedAt: Value(updatedAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }
}