import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import 'realtime_connection_controller.dart';

final realtimeBootstrapProvider = Provider<void>((ref) {
  final authState = ref.watch(authControllerProvider);

  final user = authState.user;

  if (authState.status == AuthStatus.authenticated && user != null) {
    Future.microtask(() {
      ref
          .read(realtimeConnectionControllerProvider.notifier)
          .connect(userId: user.id);
    });
  }

  if (authState.status == AuthStatus.unauthenticated) {
    Future.microtask(() {
      ref
          .read(realtimeConnectionControllerProvider.notifier)
          .disconnect();
    });
  }
});