import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<AuthUser?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return null;

      return AuthUser.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  Future<void> saveSession({
    required String token,
    required AuthUser user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_userKey, jsonEncode(user.toJson())),
    ]);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
    ]);
  }
}
