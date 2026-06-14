import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/call_debug_log.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/call_controller.dart';
import '../providers/call_state.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  const AudioCallScreen({
    super.key,
  });

  static const routePath = '/calls/active';

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _tick++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callControllerProvider);
    final debugLogs = ref.watch(callDebugLogProvider);

    ref.listen(
      callControllerProvider.select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    final call = callState.activeCall;

    final peerName = _peerName(
      currentUserId: currentUserId,
      callState: callState,
    );

    final statusText = _statusText(callState);
    final durationText = _durationText(callState);

    return PopScope(
      canPop: !callState.hasActiveCall,
      child: Scaffold(
        body: Stack(
          children: [
            const _CallBackground(),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: _CallDebugButton(
                  logs: debugLogs,
                  onCopy: () async {
                    final text = ref.read(callDebugLogProvider.notifier).exportText();

                    await Clipboard.setData(
                      ClipboardData(text: text),
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Call debug logs copied'),
                      ),
                    );
                  },
                  onClear: () {
                    ref.read(callDebugLogProvider.notifier).clear();
                  },
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Close',
                        onPressed: callState.hasActiveCall
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(
                            alpha: callState.hasActiveCall ? 0.28 : 0.92,
                          ),
                          size: 34,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _CallAvatar(
                      name: peerName,
                      isIncoming: callState.phase == CallPhase.incomingRinging,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      peerName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.45,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        durationText ?? statusText,
                        key: ValueKey('${callState.phase}-$durationText-$_tick'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (call != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Call #${call.id}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.42),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _CallActions(
                      state: callState,
                      onAccept: () {
                        ref
                            .read(callControllerProvider.notifier)
                            .acceptActiveCall();
                      },
                      onReject: () {
                        ref
                            .read(callControllerProvider.notifier)
                            .rejectActiveCall();
                      },
                      onEnd: () {
                        ref
                            .read(callControllerProvider.notifier)
                            .endActiveCall();
                      },
                      onDone: () {
                        ref
                            .read(callControllerProvider.notifier)
                            .resetCallState();

                        Navigator.of(context).maybePop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _peerName({
    required int? currentUserId,
    required CallState callState,
  }) {
    final call = callState.activeCall;

    if (call == null) return 'Audio call';

    final otherParticipant = call.otherParticipant(currentUserId);

    if (otherParticipant != null) {
      return otherParticipant.displayName;
    }

    final otherUserId = call.callerId == currentUserId
        ? call.calleeId
        : call.callerId;

    if (otherUserId != null) {
      return 'User $otherUserId';
    }

    return 'Audio call';
  }

  String _statusText(CallState state) {
    switch (state.phase) {
      case CallPhase.idle:
        return 'No active call';

      case CallPhase.starting:
        return 'Starting call...';

      case CallPhase.outgoingRinging:
        return 'Ringing...';

      case CallPhase.incomingRinging:
        return 'Incoming audio call';

      case CallPhase.accepted:
        return 'Connected';

      case CallPhase.ending:
        return 'Ending call...';

      case CallPhase.ended:
        final status = state.activeCall?.status;

        if (status == 'rejected') return 'Call declined';
        if (status == 'missed') return 'Missed call';
        if (status == 'cancelled') return 'Call cancelled';

        return 'Call ended';

      case CallPhase.failed:
        return 'Call failed';
    }
  }

  String? _durationText(CallState state) {
    if (state.phase != CallPhase.accepted) return null;

    final answeredAt = state.activeCall?.answeredAt;

    if (answeredAt == null) return 'Connected';

    final elapsed = DateTime.now().difference(answeredAt.toLocal());
    final seconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _CallAvatar extends StatelessWidget {
  final String name;
  final bool isIncoming;

  const _CallAvatar({
    required this.name,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);

    return Container(
      width: 122,
      height: 122,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFD6EAFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 38,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isIncoming)
            Positioned(
              right: 5,
              bottom: 8,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.call_received_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return '?';

    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }
}

class _CallActions extends StatelessWidget {
  final CallState state;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onEnd;
  final VoidCallback onDone;

  const _CallActions({
    required this.state,
    required this.onAccept,
    required this.onReject,
    required this.onEnd,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    if (state.phase == CallPhase.incomingRinging) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundCallButton(
            label: 'Decline',
            icon: Icons.call_end_rounded,
            color: const Color(0xFFD32F2F),
            onTap: state.isBusy ? null : onReject,
          ),
          _RoundCallButton(
            label: 'Accept',
            icon: Icons.call_rounded,
            color: const Color(0xFF2E7D32),
            onTap: state.isBusy ? null : onAccept,
          ),
        ],
      );
    }

    if (state.phase == CallPhase.ended || state.phase == CallPhase.failed) {
      return _WideCallButton(
        label: 'Done',
        icon: Icons.check_rounded,
        color: Colors.white,
        foregroundColor: const Color(0xFF0D47A1),
        onTap: onDone,
      );
    }

    return _RoundCallButton(
      label: 'End',
      icon: Icons.call_end_rounded,
      color: const Color(0xFFD32F2F),
      onTap: state.isBusy ? null : onEnd,
    );
  }
}

class _RoundCallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _RoundCallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: enabled ? 1 : 0.45),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 68,
              height: 68,
              child: Icon(
                icon,
                color: Colors.white,
                size: 31,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: enabled ? 0.90 : 0.46),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _WideCallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _WideCallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 34,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CallBackground extends StatelessWidget {
  const _CallBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: _BlurCircle(
              size: 280,
              color: Color(0xFFFFFFFF),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _BlurCircle(
              size: 320,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 62, sigmaY: 62),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _CallDebugButton extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onCopy;
  final VoidCallback onClear;

  const _CallDebugButton({
    required this.logs,
    required this.onCopy,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            builder: (context) {
              return _CallDebugSheet(
                logs: logs,
                onCopy: onCopy,
                onClear: onClear,
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bug_report_rounded,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                logs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallDebugSheet extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onCopy;
  final VoidCallback onClear;

  const _CallDebugSheet({
    required this.logs,
    required this.onCopy,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Call debug logs',
                      style: TextStyle(
                        color: Color(0xFF102033),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear'),
                  ),
                  FilledButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: logs.isEmpty
                  ? const Center(
                child: Text(
                  'No call logs yet.',
                  style: TextStyle(
                    color: Color(0xFF6B7A90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return SelectableText(
                    logs[index],
                    style: const TextStyle(
                      color: Color(0xFF102033),
                      fontSize: 12,
                      height: 1.35,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}