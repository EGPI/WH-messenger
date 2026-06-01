import 'package:flutter/material.dart';

class MessageStatusIcon extends StatelessWidget {
  final String status;

  const MessageStatusIcon({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case 'pending':
        return Icon(
          Icons.schedule_rounded,
          size: 15,
          color: Colors.grey.shade500,
        );

      case 'sent':
        return Icon(
          Icons.check_rounded,
          size: 16,
          color: Colors.grey.shade500,
        );

      case 'delivered':
        return Icon(
          Icons.done_all_rounded,
          size: 16,
          color: Colors.grey.shade500,
        );

      case 'read':
        return Icon(
          Icons.done_all_rounded,
          size: 16,
          color: colorScheme.primary,
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