import '../../data/auth_models.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isSubmitting;

  const AuthState({
    required this.status,
    required this.user,
    required this.errorMessage,
    required this.isSubmitting,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        errorMessage = null,
        isSubmitting = false;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        isSubmitting = false;

  const AuthState.authenticated(AuthUser user)
      : status = AuthStatus.authenticated,
        user = user,
        errorMessage = null,
        isSubmitting = false;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}