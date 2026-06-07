import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

// This tile is split into small private widgets, so only the list item that changes needs to rebuild from the stream.

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
    final hasUnread = unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hasUnread
                ? Colors.white
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasUnread
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: hasUnread
                    ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.045),
                blurRadius: hasUnread ? 24 : 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _ConversationAvatar(
                initials: initials,
                type: conversation.type,
                hasUnread: hasUnread,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: _ConversationTextContent(
                  title: title,
                  preview: preview,
                  hasUnread: hasUnread,
                  type: conversation.type,
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
  final bool hasUnread;

  const _ConversationAvatar({
    required this.initials,
    required this.type,
    required this.hasUnread,
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                const Color(0xFF42A5F5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: icon == null
              ? Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
              : Icon(
            icon,
            color: Colors.white,
            size: 27,
          ),
        ),
        if (hasUnread)
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF21C064),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConversationTextContent extends StatelessWidget {
  final String title;
  final String preview;
  final bool hasUnread;
  final String type;

  const _ConversationTextContent({
    required this.title,
    required this.preview,
    required this.hasUnread,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabel(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF102033),
                  fontSize: 16,
                  fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (typeLabel != null) ...[
              const SizedBox(width: 6),
              _ConversationTypePill(label: typeLabel),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasUnread
                ? const Color(0xFF243447)
                : const Color(0xFF6B7A90),
            fontSize: 14,
            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  String? _typeLabel(String type) {
    if (type == 'group') return 'Group';
    if (type == 'announcement') return 'News';
    return null;
  }
}

class _ConversationTypePill extends StatelessWidget {
  final String label;

  const _ConversationTypePill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
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

    return SizedBox(
      width: 46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread ? colorScheme.primary : const Color(0xFF8A98AA),
              fontSize: 12,
              fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: hasUnread
                ? Container(
              key: const ValueKey('unread'),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
                : const SizedBox(
              key: ValueKey('empty'),
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}