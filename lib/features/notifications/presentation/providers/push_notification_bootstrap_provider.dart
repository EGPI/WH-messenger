import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/push_notification_service.dart';

final pushNotificationBootstrapProvider = Provider<void>((ref) {
  final authState = ref.watch(authControllerProvider);
  final service = ref.watch(pushNotificationServiceProvider);

  ref.listen<AuthState>(authControllerProvider, (_, next) {
    _syncPushNotifications(service, next);
  });

  _syncPushNotifications(service, authState);
});

void _syncPushNotifications(
  PushNotificationService service,
  AuthState authState,
) {
  if (authState.status == AuthStatus.authenticated && authState.user != null) {
    Future.microtask(() {
      unawaited(service.start());
    });
  }

  if (authState.status == AuthStatus.unauthenticated) {
    Future.microtask(() {
      unawaited(service.stop());
    });
  }
}
