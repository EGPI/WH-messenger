import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

//This tile is split into small private widgets, so only the list item that changes needs to rebuild from the stream.

class ConversationTile extends StatelessWidget {
  final LocalConversation conversation;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _conversationTitle(conversation);
    final preview = _conversationPreview(conversation);
    final timeLabel = _formatTime(conversation.lastMessageAt);
    final initials = _initials(title);
    final unreadCount = conversation.unreadCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            _ConversationAvatar(
              initials: initials,
              type: conversation.type,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConversationTextContent(
                title: title,
                preview: preview,
                hasUnread: unreadCount > 0,
              ),
            ),
            const SizedBox(width: 12),
            _ConversationTrailing(
              timeLabel: timeLabel,
              unreadCount: unreadCount,
            ),
          ],
        ),
      ),
    );
  }

  String _conversationTitle(LocalConversation conversation) {
    final title = conversation.title?.trim();

    if (title != null && title.isNotEmpty) {
      return title;
    }

    if (conversation.type == 'direct') {
      return 'Unknown user';
    }

    if (conversation.type == 'announcement') {
      return 'Announcement';
    }

    return 'Group chat';
  }

  String _conversationPreview(LocalConversation conversation) {
    final preview = conversation.lastMessagePreview?.trim();

    if (preview != null && preview.isNotEmpty) {
      return preview;
    }

    if (conversation.type == 'announcement') {
      return 'No announcements yet';
    }

    return 'No messages yet';
  }

  String _initials(String title) {
    final trimmed = title.trim();

    if (trimmed.isEmpty) return '?';

    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }

    return '${words.first.characters.first}${words[1].characters.first}'
        .toUpperCase();
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';

    final now = DateTime.now();
    final local = value.toLocal();

    final isToday = now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;

    if (isToday) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _ConversationAvatar extends StatelessWidget {
  final String initials;
  final String type;

  const _ConversationAvatar({
    required this.initials,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData? icon;

    if (type == 'group') {
      icon = Icons.groups_rounded;
    } else if (type == 'announcement') {
      icon = Icons.campaign_rounded;
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      child: icon == null
          ? Text(
        initials,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      )
          : Icon(
        icon,
        color: colorScheme.primary,
      ),
    );
  }
}

class _ConversationTextContent extends StatelessWidget {
  final String title;
  final String preview;
  final bool hasUnread;

  const _ConversationTextContent({
    required this.title,
    required this.preview,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasUnread ? Colors.black87 : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ConversationTrailing extends StatelessWidget {
  final String timeLabel;
  final int unreadCount;

  const _ConversationTrailing({
    required this.timeLabel,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasUnread = unreadCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeLabel,
          style: TextStyle(
            color: hasUnread ? colorScheme.primary : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 7),
        if (hasUnread)
          Container(
            constraints: const BoxConstraints(
              minWidth: 22,
              minHeight: 22,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          const SizedBox(height: 22),
      ],
    );
  }
}