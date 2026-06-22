import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class CallMessageBubble extends StatelessWidget {
  final LocalMessage message;
  final bool isMine;

  const CallMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final payload = _decodePayload(message.payloadJson);
    final status = payload['call_status']?.toString() ?? 'ended';
    final callType = payload['call_type']?.toString() ?? 'audio';
    final durationSeconds = _parseInt(payload['duration_seconds']) ?? 0;

    final display = _displayForStatus(
      status: status,
      callType: callType,
      durationSeconds: durationSeconds,
      isMine: isMine,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: RepaintBoundary(
        child: Container(
          margin: EdgeInsets.only(
            left: isMine ? 74 : 14,
            right: isMine ? 14 : 74,
            top: 5,
            bottom: 5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isMine ? 22 : 7),
              bottomRight: Radius.circular(isMine ? 7 : 22),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.96),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: display.isMissed
                        ? const Color(0xFFFFEBEE)
                        : colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    display.icon,
                    color: display.isMissed
                        ? const Color(0xFFD32F2F)
                        : colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: display.isMissed
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF102033),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        display.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7A90),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _CallMessageDisplay _displayForStatus({
    required String status,
    required String callType,
    required int durationSeconds,
    required bool isMine,
  }) {
    final normalizedStatus = status.trim().toLowerCase();
    final normalizedType = callType.trim().toLowerCase();
    final typeLabel = normalizedType == 'audio' ? 'Audio call' : 'Call';

    switch (normalizedStatus) {
      case 'missed':
        if (isMine) {
          return _CallMessageDisplay(
            icon: Icons.call_made_rounded,
            title: typeLabel,
            subtitle: 'No answer',
            isMissed: false,
          );
        }

        return const _CallMessageDisplay(
          icon: Icons.call_missed_rounded,
          title: 'Missed audio call',
          subtitle: 'Tap the phone button to call back',
          isMissed: true,
        );

      case 'rejected':
        return _CallMessageDisplay(
          icon: isMine ? Icons.call_made_rounded : Icons.call_received_rounded,
          title: typeLabel,
          subtitle: 'Declined',
          isMissed: false,
        );

      case 'cancelled':
        if (isMine) {
          return _CallMessageDisplay(
            icon: Icons.call_made_rounded,
            title: typeLabel,
            subtitle: 'Cancelled',
            isMissed: false,
          );
        }

        return const _CallMessageDisplay(
          icon: Icons.call_missed_rounded,
          title: 'Missed audio call',
          subtitle: 'Caller cancelled',
          isMissed: true,
        );

      case 'failed':
        return _CallMessageDisplay(
          icon: Icons.call_end_rounded,
          title: typeLabel,
          subtitle: 'Failed',
          isMissed: true,
        );

      case 'ended':
      default:
        return _CallMessageDisplay(
          icon: isMine ? Icons.call_made_rounded : Icons.call_received_rounded,
          title: typeLabel,
          subtitle: durationSeconds > 0
              ? _formatDuration(durationSeconds)
              : 'Completed',
          isMissed: false,
        );
    }
  }

  Map<String, dynamic> _decodePayload(String? value) {
    if (value == null || value.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
              (key, value) => MapEntry(
            key.toString(),
            value,
          ),
        );
      }
    } catch (_) {
      // Fall back to an empty payload.
    }

    return <String, dynamic>{};
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  String _formatDuration(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      return '${hours}h ${remainingMinutes}m';
    }

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _CallMessageDisplay {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isMissed;

  const _CallMessageDisplay({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isMissed,
  });
}