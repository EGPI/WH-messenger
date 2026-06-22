import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../realtime/presentation/providers/realtime_bootstrap_provider.dart';
import '../providers/call_controller.dart';
import '../providers/call_state.dart';
import '../screens/audio_call_screen.dart';

class CallNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallNavigationListener({super.key, required this.child});

  @override
  ConsumerState<CallNavigationListener> createState() =>
      _CallNavigationListenerState();
}

class _CallNavigationListenerState
    extends ConsumerState<CallNavigationListener> {
  int? _lastOpenedIncomingCallId;
  bool _isOpeningCallScreen = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(realtimeBootstrapProvider);
    final callState = ref.watch(callControllerProvider);

    ref.listen<CallState>(callControllerProvider, (previous, next) {
      _handleCallStateChanged(next);
    });

    return Stack(
      children: [
        widget.child,
        if (callState.hasActiveCall && callState.isScreenMinimized)
          _MinimizedCallBubble(state: callState, onTap: _openActiveCallScreen),
      ],
    );
  }

  void _openActiveCallScreen() {
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(callControllerProvider.notifier).restoreCallScreen();
    ref.read(routerProvider).push(AudioCallScreen.routePath);
  }

  void _handleCallStateChanged(CallState state) {
    final call = state.activeCall;

    if (state.phase == CallPhase.idle ||
        state.phase == CallPhase.ended ||
        state.phase == CallPhase.failed) {
      _isOpeningCallScreen = false;
      _lastOpenedIncomingCallId = null;
      return;
    }

    if (state.phase != CallPhase.incomingRinging || call == null) {
      return;
    }

    if (_isOpeningCallScreen && _lastOpenedIncomingCallId == call.id) {
      return;
    }

    _isOpeningCallScreen = true;
    _lastOpenedIncomingCallId = call.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(routerProvider).push(AudioCallScreen.routePath);
    });
  }
}

class _MinimizedCallBubble extends StatefulWidget {
  final CallState state;
  final VoidCallback onTap;

  const _MinimizedCallBubble({required this.state, required this.onTap});

  @override
  State<_MinimizedCallBubble> createState() => _MinimizedCallBubbleState();
}

class _MinimizedCallBubbleState extends State<_MinimizedCallBubble> {
  static const Size _bubbleSize = Size(86, 58);
  static const double _edgePadding = 14;

  Offset? _position;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bounds = _BubbleBounds(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            safeTop: padding.top,
            safeBottom: padding.bottom,
          );
          final position = _clampedPosition(bounds);

          return Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap,
                  onPanStart: (_) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _position = bounds.clamp(position + details.delta);
                    });
                  },
                  onPanEnd: (_) {
                    final current = _clampedPosition(bounds);
                    final snapLeft =
                        current.dx < (bounds.maxWidth - _bubbleSize.width) / 2;

                    setState(() {
                      _isDragging = false;
                      _position = bounds.clamp(
                        Offset(
                          snapLeft ? bounds.minX : bounds.maxX,
                          current.dy,
                        ),
                      );
                    });
                  },
                  onPanCancel: () {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 120),
                    scale: _isDragging ? 1.04 : 1,
                    child: Material(
                      color: Colors.transparent,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: _bubbleSize.width,
                          height: _bubbleSize.height,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _shortLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _clampedPosition(_BubbleBounds bounds) {
    return bounds.clamp(_position ?? bounds.defaultPosition);
  }

  String get _shortLabel {
    switch (widget.state.phase) {
      case CallPhase.incomingRinging:
        return 'Call';
      case CallPhase.outgoingRinging:
        return 'Ring';
      case CallPhase.accepted:
        return 'Live';
      case CallPhase.starting:
        return 'Call';
      case CallPhase.ending:
        return 'End';
      case CallPhase.idle:
      case CallPhase.ended:
      case CallPhase.failed:
        return 'Call';
    }
  }
}

class _BubbleBounds {
  final double maxWidth;
  final double maxHeight;
  final double safeTop;
  final double safeBottom;

  const _BubbleBounds({
    required this.maxWidth,
    required this.maxHeight,
    required this.safeTop,
    required this.safeBottom,
  });

  double get minX => _MinimizedCallBubbleState._edgePadding;

  double get maxX {
    final value = maxWidth - _MinimizedCallBubbleState._bubbleSize.width - minX;

    return value < minX ? minX : value;
  }

  double get minY => safeTop + 74;

  double get maxY {
    final value =
        maxHeight -
        safeBottom -
        _MinimizedCallBubbleState._bubbleSize.height -
        86;

    return value < minY ? minY : value;
  }

  Offset get defaultPosition {
    return Offset(maxX, minY);
  }

  Offset clamp(Offset position) {
    final left = position.dx.clamp(minX, maxX).toDouble();
    final top = position.dy.clamp(minY, maxY).toDouble();

    return Offset(left, top);
  }
}
