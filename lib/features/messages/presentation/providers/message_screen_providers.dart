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

const String announcementSendBlockedReason =
    'Only admins and owners can send messages in announcement chats.';

class MessageSendPermission {
  final bool canSend;
  final String? blockedReason;

  const MessageSendPermission._({
    required this.canSend,
    required this.blockedReason,
  });

  const MessageSendPermission.canSend()
      : this._(
    canSend: true,
    blockedReason: null,
  );

  const MessageSendPermission.blocked(String reason)
      : this._(
    canSend: false,
    blockedReason: reason,
  );

  factory MessageSendPermission.fromConversation({
    required String? type,
    required String? myRole,
  }) {
    final normalizedType = type?.trim().toLowerCase();
    final normalizedRole = myRole?.trim().toLowerCase();

    final isAnnouncement = normalizedType == 'announcement';
    final isAdminOrOwner =
        normalizedRole == 'admin' || normalizedRole == 'owner';

    if (isAnnouncement && !isAdminOrOwner) {
      return const MessageSendPermission.blocked(
        announcementSendBlockedReason,
      );
    }

    return const MessageSendPermission.canSend();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MessageSendPermission &&
            runtimeType == other.runtimeType &&
            canSend == other.canSend &&
            blockedReason == other.blockedReason;
  }

  @override
  int get hashCode => Object.hash(
    canSend,
    blockedReason,
  );
}

final messageSendPermissionProvider =
Provider.family<MessageSendPermission, int>((ref, conversationId) {
  final conversationAsync = ref.watch(
    localConversationProvider(conversationId),
  );

  return conversationAsync.maybeWhen(
    data: (conversation) {
      return MessageSendPermission.fromConversation(
        type: conversation?.type,
        myRole: conversation?.myRole,
      );
    },
    orElse: () => const MessageSendPermission.canSend(),
  );
});

final messageSenderNamesProvider =
StreamProvider.family<Map<int, String>, int>((ref, conversationId) {
  final dao = ref.watch(chatLocalDaoProvider);

  return dao
      .watchConversationParticipantsWithUsersIncludingRemoved(conversationId)
      .map((participants) {
    final result = <int, String>{};

    for (final item in participants) {
      final name = item.user.name.trim();

      if (name.isEmpty) continue;

      result[item.user.id] = name;
    }

    return result;
  });
});