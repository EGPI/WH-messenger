import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import 'message_status_icon.dart';

class MessageBubble extends StatelessWidget {
  final LocalMessage message;
  final bool isMine;
  final bool showSenderName;
  final String? senderName;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderName,
    this.senderName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == 'system') {
      return _SystemMessageRow(message: message);
    }

    final colorScheme = Theme.of(context).colorScheme;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(isMine ? 22 : 6),
      bottomRight: Radius.circular(isMine ? 6 : 22),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: isMine && message.status == 'failed' ? onRetry : null,
        child: RepaintBoundary(
          child: Container(
            margin: EdgeInsets.only(
              left: isMine ? 58 : 14,
              right: isMine ? 14 : 58,
              top: 4,
              bottom: 4,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: isMine
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  const Color(0xFF0D47A1),
                ],
              )
                  : null,
              color: isMine ? null : Colors.white.withValues(alpha: 0.94),
              borderRadius: borderRadius,
              border: isMine
                  ? null
                  : Border.all(
                color: Colors.white.withValues(alpha: 0.96),
              ),
              boxShadow: [
                BoxShadow(
                  color: isMine
                      ? colorScheme.primary.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.055),
                  blurRadius: isMine ? 16 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSenderName && !isMine) ...[
                    Text(
                      _safeSenderName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isMine ? Colors.white : const Color(0xFF102033),
                      fontSize: 15.5,
                      height: 1.34,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _BubbleFooter(
                    isMine: isMine,
                    message: message,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _safeSenderName() {
    final trimmed = senderName?.trim();

    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    return 'User ${message.senderId}';
  }

}

class _SystemMessageRow extends StatelessWidget {
  final LocalMessage message;

  const _SystemMessageRow({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final body = message.body.trim();

    if (body.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 7,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleFooter extends StatelessWidget {
  final bool isMine;
  final LocalMessage message;

  const _BubbleFooter({
    required this.isMine,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatServerTime(message.serverReceivedAt);

    final footerColor = isMine
        ? Colors.white.withValues(alpha: 0.78)
        : const Color(0xFF8A98AA);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (timeLabel.isNotEmpty)
          Text(
            timeLabel,
            style: TextStyle(
              color: footerColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (isMine) ...[
          const SizedBox(width: 5),
          MessageStatusIcon(
            status: message.status,
            isMine: isMine,
          ),
          if (message.status == 'failed') ...[
            const SizedBox(width: 5),
            const Text(
              'Tap to retry',
              style: TextStyle(
                color: Color(0xFFFFD6D6),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ],
    );
  }

  String _formatServerTime(DateTime? value) {
    if (value == null) return '';

    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}