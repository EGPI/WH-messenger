import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../realtime/presentation/providers/realtime_bootstrap_provider.dart';
import '../providers/call_controller.dart';
import '../providers/call_state.dart';
import '../screens/audio_call_screen.dart';

class CallNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallNavigationListener({
    super.key,
    required this.child,
  });

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

    ref.listen<CallState>(
      callControllerProvider,
          (previous, next) {
        _handleCallStateChanged(next);
      },
    );

    return widget.child;
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