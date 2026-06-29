import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/database/daos/chat_local_dao.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

final localMessagesProvider = StreamProvider.family<List<LocalMessage>, int>((
  ref,
  conversationId,
) {
  final dao = ref.watch(chatLocalDaoProvider);
  return dao.watchMessages(conversationId);
});

final openConversationIdProvider = StateProvider<int?>((ref) {
  return null;
});

final localConversationProvider =
    StreamProvider.family<LocalConversation?, int>((ref, conversationId) {
      final database = ref.watch(appDatabaseProvider);

      return (database.select(
        database.localConversations,
      )..where((t) => t.id.equals(conversationId))).watchSingleOrNull();
    });

const String announcementSendBlockedReason =
    'Only admins and owners can send messages in announcement chats.';
const String deletedAccountBlockedReason =
    'This account was deleted. You cannot send messages or call this user.';

bool isDeletedAccountName(String? value) {
  return value?.trim().toLowerCase() == 'deleted user';
}

class MessageSendPermission {
  final bool canSend;
  final String? blockedReason;

  const MessageSendPermission._({
    required this.canSend,
    required this.blockedReason,
  });

  const MessageSendPermission.canSend()
    : this._(canSend: true, blockedReason: null);

  const MessageSendPermission.blocked(String reason)
    : this._(canSend: false, blockedReason: reason);

  factory MessageSendPermission.fromConversation({
    required String? type,
    required String? myRole,
    required bool isDirectPeerDeleted,
  }) {
    final normalizedType = type?.trim().toLowerCase();
    final normalizedRole = myRole?.trim().toLowerCase();

    if ((normalizedType == null || normalizedType == 'direct') &&
        isDirectPeerDeleted) {
      return const MessageSendPermission.blocked(deletedAccountBlockedReason);
    }

    final isAnnouncement = normalizedType == 'announcement';
    final isAdminOrOwner =
        normalizedRole == 'admin' || normalizedRole == 'owner';

    if (isAnnouncement && !isAdminOrOwner) {
      return const MessageSendPermission.blocked(announcementSendBlockedReason);
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
  int get hashCode => Object.hash(canSend, blockedReason);
}

final messageSendPermissionProvider =
    Provider.family<MessageSendPermission, int>((ref, conversationId) {
      final conversationAsync = ref.watch(
        localConversationProvider(conversationId),
      );
      final peerStatusAsync = ref.watch(
        directChatPeerStatusProvider(conversationId),
      );

      return conversationAsync.maybeWhen(
        data: (conversation) {
          final titleIsDeletedUser = isDeletedAccountName(conversation?.title);
          final isPeerDeleted =
              peerStatusAsync.valueOrNull?.isDeletedOrInactive;

          return MessageSendPermission.fromConversation(
            type: conversation?.type,
            myRole: conversation?.myRole,
            isDirectPeerDeleted: titleIsDeletedUser || (isPeerDeleted ?? false),
          );
        },
        orElse: () => const MessageSendPermission.canSend(),
      );
    });

class DirectChatPeerStatus {
  final bool isDeletedOrInactive;

  const DirectChatPeerStatus({required this.isDeletedOrInactive});

  const DirectChatPeerStatus.available() : isDeletedOrInactive = false;
  const DirectChatPeerStatus.deleted() : isDeletedOrInactive = true;
}

DirectChatPeerStatus directChatPeerStatusFromParticipants({
  required List<LocalConversationParticipantWithUser> participants,
  required int? currentUserId,
}) {
  if (currentUserId == null) {
    return const DirectChatPeerStatus.available();
  }

  for (final item in participants) {
    final user = item.user;

    if (user.id == currentUserId) continue;

    final isDeletedOrInactive =
        item.participant.leftAt != null ||
        !user.isActive ||
        isDeletedAccountName(user.name);

    if (isDeletedOrInactive) {
      return const DirectChatPeerStatus.deleted();
    }
  }

  return const DirectChatPeerStatus.available();
}

final directChatPeerStatusProvider =
    StreamProvider.family<DirectChatPeerStatus, int>((ref, conversationId) {
      final currentUserId = ref.watch(
        authControllerProvider.select((state) => state.user?.id),
      );
      final dao = ref.watch(chatLocalDaoProvider);

      return dao
          .watchConversationParticipantsWithUsersIncludingRemoved(
            conversationId,
          )
          .map((participants) {
            return directChatPeerStatusFromParticipants(
              participants: participants,
              currentUserId: currentUserId,
            );
          });
    });

final messageSenderNamesProvider = StreamProvider.family<Map<int, String>, int>(
  (ref, conversationId) {
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
  },
);
