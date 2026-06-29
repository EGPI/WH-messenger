import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../notifications/data/push_notification_service.dart';
import '../../data/auth_api.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late final AuthApi _authApi;
  late final _storage = ref.read(authStorageProvider);

  @override
  AuthState build() {
    _authApi = ref.read(authApiProvider);
    _restoreSession();
    return const AuthState.unknown();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.readToken();

    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    final cachedUser = await _storage.readUser();

    if (cachedUser != null) {
      state = AuthState.authenticated(cachedUser);
    }

    try {
      final freshUser = await _authApi.me();

      await _storage.saveUser(freshUser);

      state = AuthState.authenticated(freshUser);
      unawaited(ref.read(pushNotificationServiceProvider).start());
    } catch (_) {
      await _storage.clearToken();

      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final result = await _authApi.login(
        email: email.trim(),
        password: password,
      );

      await _storage.saveSession(token: result.token, user: result.user);

      state = AuthState.authenticated(result.user);
      unawaited(ref.read(pushNotificationServiceProvider).start());
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final result = await _authApi.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      await _storage.saveSession(token: result.token, user: result.user);

      state = AuthState.authenticated(result.user);
      unawaited(ref.read(pushNotificationServiceProvider).start());
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(pushNotificationServiceProvider).revokeCurrentDevice();
    await ref.read(pushNotificationServiceProvider).stop();

    try {
      await _authApi.logout();
    } catch (_) {
      // Even if server logout fails, clear local token.
    }

    await _clearLocalSession(clearChatCache: false);
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _authApi.deleteAccount();
      await ref.read(pushNotificationServiceProvider).stop();
      await _clearLocalSession(clearChatCache: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<void> _clearLocalSession({required bool clearChatCache}) async {
    await _storage.clearToken();

    if (clearChatCache) {
      await ref.read(chatLocalDaoProvider).clearLocalChatCache();
    }

    state = const AuthState.unauthenticated();
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timeout. Please try again.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to the server.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
