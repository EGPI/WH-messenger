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
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!hasMoreOlder) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            'No older messages',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}