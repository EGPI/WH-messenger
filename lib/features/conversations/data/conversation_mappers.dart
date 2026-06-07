import 'package:drift/drift.dart';
import 'conversation_details_models.dart';
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
extension ConversationDetailsModelMapper on ConversationDetailsModel {
  LocalConversationsCompanion toLocalConversationCompanion() {
    return LocalConversationsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      myRole: Value(myRole),
      updatedAt: Value(updatedAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }
}

extension ConversationParticipantModelMapper on ConversationParticipantModel {
  LocalUsersCompanion toLocalUserCompanion() {
    return LocalUsersCompanion(
      id: Value(userId),
      name: Value(name),
      email: Value(email),
      avatarUrl: Value(avatarUrl),
      phone: Value(phone),
      isActive: Value(isActive),
      lastSeenAt: Value(lastSeenAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }

  LocalConversationParticipantsCompanion toLocalParticipantCompanion({
    required int fallbackConversationId,
  }) {
    final safeConversationId =
    conversationId == 0 ? fallbackConversationId : conversationId;

    return LocalConversationParticipantsCompanion(
      conversationId: Value(safeConversationId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
      leftAt: Value(leftAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }
}