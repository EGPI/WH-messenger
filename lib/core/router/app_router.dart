import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/conversations/presentation/screens/conversations_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: LoginScreen.routePath,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == LoginScreen.routePath ||
          state.matchedLocation == SignupScreen.routePath;

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : LoginScreen.routePath;
      }

      if (authState.status == AuthStatus.authenticated && isAuthRoute) {
        return ConversationsScreen.routePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: LoginScreen.routePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignupScreen.routePath,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: ConversationsScreen.routePath,
        builder: (context, state) => const ConversationsScreen(),
      ),
    ],
  );
});