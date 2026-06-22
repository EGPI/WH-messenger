class AuthValidators {
  static final RegExp _egpiEmailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@egpi\.com$',
    caseSensitive: false,
  );

  AuthValidators._();

  static String? name(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) return 'Please enter your name.';
    if (name.length < 2) return 'Name must be at least 2 characters.';

    return null;
  }

  static String? egpiEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Please enter your EGPI email address.';
    if (!_egpiEmailPattern.hasMatch(email)) {
      return 'Use company email,for example name@egpi.com';
    }

    return null;
  }

  static String? requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter your password.';

    return null;
  }

  static String? strongPassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter your password.';
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password needs at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password needs at least one lowercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password needs at least one number.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password needs at least one special character.';
    }

    return null;
  }
}
