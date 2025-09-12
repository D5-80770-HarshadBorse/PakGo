import 'package:flutter/material.dart';
import 'package:pakgo/core/constants/app_routes_constants.dart';
import 'package:pakgo/features/auth/screens/SignupScreen.dart';
import 'package:pakgo/features/auth/screens/login.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';

class AppRoutesInitializer {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _fadeRoute(const LoginScreen());
      case AppRoutes.signup:
        return _fadeRoute(const SignupScreen());
      case AppRoutes.home:
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
