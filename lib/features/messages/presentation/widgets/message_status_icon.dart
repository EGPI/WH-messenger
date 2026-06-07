import 'package:flutter/material.dart';

class MessageStatusIcon extends StatelessWidget {
  final String status;
  final bool isMine;

  const MessageStatusIcon({
    super.key,
    required this.status,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final normalColor = isMine
        ? Colors.white.withValues(alpha: 0.78)
        : Colors.grey.shade500;

    const readColor = Color(0xFF4FC3F7);

    switch (status) {
      case 'pending':
        return Icon(
          Icons.schedule_rounded,
          size: 15,
          color: normalColor,
        );

      case 'sent':
        return Icon(
          Icons.check_rounded,
          size: 16,
          color: normalColor,
        );

      case 'delivered':
        return Icon(
          Icons.done_all_rounded,
          size: 16,
          color: normalColor,
        );

      case 'read':
        return const Icon(
          Icons.done_all_rounded,
          size: 16,
          color: readColor,
        );

      case 'failed':
        return const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: Colors.redAccent,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}