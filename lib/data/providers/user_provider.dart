import 'package:flutter/material.dart';
import 'package:pakgo/core/constants/auth_status.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/user.dart';
import 'package:pakgo/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  final UserService userService = UserService();

  AuthStatus _status = AuthStatus.Uninitialized;

  // Getters
  User? get user => _user;
  String? get token => _token;
  AuthStatus get status => _status;

  bool get isLoggedIn => _status == AuthStatus.Authenticated;

  Future<void> login(User user, String token) async {
    _user = user;
    _token = token;
    _status = AuthStatus.Authenticated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    ApiClient().setAuthToken(token);

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _status = AuthStatus.Unauthenticated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ApiClient().clearAuthToken();

    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    _status = AuthStatus.Authenticating;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) {
      _status = AuthStatus.Unauthenticated;

      notifyListeners();
      return;
    }
    final savedToken = prefs.getString('auth_token')!;
    _token = savedToken;
    ApiClient().setAuthToken(savedToken);

    try {
      final loadedUser = await userService.fetchProfile();
      _user = loadedUser;
      _status = AuthStatus.Authenticated;

      notifyListeners();
    } catch (e) {
      await logout();
    }
  }
}
