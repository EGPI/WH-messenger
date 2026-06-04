import 'package:flutter/material.dart';

class OlderMessagesLoader extends StatelessWidget {
  final bool isLoadingOlder;
  final bool hasMoreOlder;

  const OlderMessagesLoader({
    super.key,
    required this.isLoadingOlder,
    required this.hasMoreOlder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingOlder) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: _OlderMessagesLoadingPill(),
        ),
      );
    }

    if (!hasMoreOlder) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: _OlderMessagesEndPill(),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}

class _OlderMessagesLoadingPill extends StatelessWidget {
  const _OlderMessagesLoadingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.94),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 9),
          Text(
            'Loading older messages',
            style: TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OlderMessagesEndPill extends StatelessWidget {
  const _OlderMessagesEndPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
        ),
      ),
      child: const Text(
        'No older messages',
        style: TextStyle(
          color: Color(0xFF8A98AA),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}