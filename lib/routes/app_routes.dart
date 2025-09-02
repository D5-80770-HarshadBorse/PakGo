import 'package:flutter/material.dart';
import 'package:pakgo/features/auth/screens/SignupScreen.dart';
import 'package:pakgo/features/auth/screens/login.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen());
      case signup:
        return _fadeRoute(const SignupScreen());
      case home:
        return _fadeRoute(const HomeScreen());
      default:
        return _fadeRoute(const LoginScreen()); // fallback
    }
  }

  // Reusable fade transition
  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
