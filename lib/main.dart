import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'features/notifications/data/push_notification_service.dart';
import 'features/notifications/presentation/providers/push_notification_bootstrap_provider.dart';
import 'features/calls/presentation/widgets/call_navigation_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await PushNotificationService.initializeFirebase();

  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pushNotificationBootstrapProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return CallNavigationListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
