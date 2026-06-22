import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/call_controller.dart';
import '../providers/call_state.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  const AudioCallScreen({super.key});

  static const routePath = '/calls/active';

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
  Timer? _timer;
  int _tick = 0;
  bool _isDismissing = false;
  bool _isMinimizing = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      ref.read(callControllerProvider.notifier).restoreCallScreen();
    });

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

    if (!_isDismissing && !_isMinimizing) {
      final callState = ref.read(callControllerProvider);
      final call = callState.activeCall;

      if (call != null && !call.isFinished) {
        unawaited(
          ref.read(callControllerProvider.notifier).dismissCallScreen(),
        );
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callControllerProvider);
    ref.listen(callControllerProvider.select((state) => state.errorMessage), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
    });

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    final peerName = _peerName(
      currentUserId: currentUserId,
      callState: callState,
    );

    final statusText = _statusText(callState);
    final durationText = _durationText(callState);

    return PopScope(
      canPop: _isMinimizing || !callState.hasActiveCall,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const _CallBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: callState.hasActiveCall
                            ? 'Minimize call'
                            : 'Close',
                        onPressed: callState.hasActiveCall
                            ? _minimizeCallScreen
                            : () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.92),
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
                        key: ValueKey(
                          '${callState.phase}-$durationText-$_tick',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (callState.phase == CallPhase.accepted) ...[
                      _AudioModeControls(
                        state: callState,
                        onToggleMuted: () {
                          unawaited(
                            ref
                                .read(callControllerProvider.notifier)
                                .toggleMuted(),
                          );
                        },
                        onToggleSpeaker: () {
                          unawaited(
                            ref
                                .read(callControllerProvider.notifier)
                                .toggleSpeakerphone(),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],
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
                        _dismissCallScreen();
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

  void _dismissCallScreen() {
    if (_isDismissing) return;

    _isDismissing = true;

    unawaited(
      ref
          .read(callControllerProvider.notifier)
          .dismissCallScreen()
          .whenComplete(() {
            if (!mounted) return;

            Navigator.of(context).maybePop();
          }),
    );
  }

  Future<void> _minimizeCallScreen() async {
    if (_isMinimizing) return;

    setState(() {
      _isMinimizing = true;
    });

    ref.read(callControllerProvider.notifier).minimizeCallScreen();
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    ref.read(routerProvider).go('/conversations');
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

  const _CallAvatar({required this.name, required this.isIncoming});

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
          colors: [Color(0xFFFFFFFF), Color(0xFFD6EAFF)],
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
                  border: Border.all(color: Colors.white, width: 3),
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

class _AudioModeControls extends StatelessWidget {
  final CallState state;
  final VoidCallback onToggleMuted;
  final VoidCallback onToggleSpeaker;

  const _AudioModeControls({
    required this.state,
    required this.onToggleMuted,
    required this.onToggleSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !state.isBusy;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundCallButton(
          label: state.isMuted ? 'Unmute' : 'Mute',
          icon: state.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: state.isMuted ? Colors.white : const Color(0x332A5C9E),
          foregroundColor: state.isMuted
              ? const Color(0xFF0D47A1)
              : Colors.white,
          onTap: enabled ? onToggleMuted : null,
        ),
        const SizedBox(width: 28),
        _RoundCallButton(
          label: state.isSpeakerphoneEnabled ? 'Speaker' : 'Earpiece',
          icon: state.isSpeakerphoneEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_down_rounded,
          color: state.isSpeakerphoneEnabled
              ? Colors.white
              : const Color(0x332A5C9E),
          foregroundColor: state.isSpeakerphoneEnabled
              ? const Color(0xFF0D47A1)
              : Colors.white,
          onTap: enabled ? onToggleSpeaker : null,
        ),
      ],
    );
  }
}

class _RoundCallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _RoundCallButton({
    required this.label,
    required this.icon,
    required this.color,
    this.foregroundColor = Colors.white,
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
              child: Icon(icon, color: foregroundColor, size: 31),
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
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
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
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: _BlurCircle(size: 280, color: Color(0xFFFFFFFF)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _BlurCircle(size: 320, color: Color(0xFFFFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

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
