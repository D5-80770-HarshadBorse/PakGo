import 'package:flutter/material.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/user.dart';
import 'package:pakgo/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer'; // <-- IMPORT THIS
import 'package:logging/logging.dart'; // For Level constants

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  final UserService userService = UserService();

  User? get user => _user;

  String? get token => _token;

  bool get isLoggedIn => _token != null && _user != null;

  Future<void> login(User user, String token) async {
    _user = user;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    ApiClient().setAuthToken(token);

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    ApiClient().clearAuthToken();

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    log(
      '[AUTH] 🔄 Starting auto-login check...',
      name: 'UserProvider',
      level: Level.INFO.value,
    );

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) {
      log('[AUTH] ❌ No auth token found. Aborting auto-login.', name: 'UserProvider');
      return false;
    }

    final savedToken = prefs.getString('auth_token')!;
    log('[AUTH] 🔑 Token found in storage. Setting in ApiClient.', name: 'UserProvider');
    _token = savedToken;
    ApiClient().setAuthToken(savedToken);

    try {
      log('[AUTH] ⏳ Fetching user profile from server...', name: 'UserProvider');
      final userService = UserService();
      final loadedUser = await userService.fetchProfile();
      _user = loadedUser;

      log(
        '[AUTH] ✅ Profile fetched successfully for user: ${_user?.name}.',
        name: 'UserProvider',
        level: Level.INFO.value,
      );
      notifyListeners();
      log('[AUTH] 👍 Auto-login successful.', name: 'UserProvider');
      return true;
    } catch (e, stackTrace) {
      log(
        '[AUTH] 🔥 An error occurred during profile fetch. Logging out.',
        name: 'UserProvider',
        level: Level.SEVERE.value, // SEVERE is great for errors
        error: e,
        stackTrace: stackTrace,
      );
      await logout(); // Your existing logout method
      return false;
    }
  }
}
