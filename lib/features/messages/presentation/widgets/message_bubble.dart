import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import 'message_status_icon.dart';

class MessageBubble extends StatelessWidget {
  final LocalMessage message;
  final bool isMine;
  final bool showSenderName;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = isMine ? colorScheme.primary : Colors.white;
    final textColor = isMine ? Colors.white : Colors.black87;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMine ? 18 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 18),
    );

    return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: isMine && message.status == 'failed' ? onRetry : null,
          child: RepaintBoundary(
        child: Container(
          margin: EdgeInsets.only(
            left: isMine ? 54 : 12,
            right: isMine ? 12 : 54,
            top: 3,
            bottom: 3,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            border: isMine
                ? null
                : Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                    'User ${message.senderId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message.body,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                _BubbleFooter(
                  isMine: isMine,
                  message: message,
                ),
              ],
            ),
          ),
        ),
      ),
          )
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
        : Colors.grey.shade500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (timeLabel.isNotEmpty)
          Text(
            timeLabel,
            style: TextStyle(
              color: footerColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (isMine) ...[
          const SizedBox(width: 4),
          MessageStatusIcon(
            status: message.status,
            isMine: isMine,
          ),
          if (message.status == 'failed') ...[
            const SizedBox(width: 4),
            const Text(
              'Tap to retry',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
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