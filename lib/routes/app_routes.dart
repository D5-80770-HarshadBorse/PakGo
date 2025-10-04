import 'package:flutter/material.dart';
import 'package:pakgo/features/auth/screens/SignupScreen.dart';
import 'package:pakgo/features/auth/screens/login.dart';
import 'package:pakgo/features/auth/screens/splash_screen.dart';
import 'package:pakgo/features/book/screen/booking_location_screen.dart';
import 'package:pakgo/features/book/screen/confirmation_screen.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';
import 'package:pakgo/features/tracking/screens/tracking_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const locationPickerMap = '/location_picker_map';
  static const bookingConfirmation = '/booking-confirmation';
  static const splash = '/splash';
  static const tracking = '/tracking';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen());
      case signup:
        return _fadeRoute(const SignupScreen());
      case home:
        return _fadeRoute(const HomeScreen());
      case locationPickerMap:
        return _fadeRoute(const BookingLocation());
      case bookingConfirmation:
        return _fadeRoute(const ConfirmationScreen());
      case splash:
        return _fadeRoute(const SplashScreen());
      case tracking:
        return _fadeRoute(const TrackingScreen());
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
