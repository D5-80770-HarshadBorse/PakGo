import 'package:flutter/material.dart';
import 'package:pakgo/core/constants/auth_status.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/login.dart'; // Ensure this is your correct LoginScreen import
import 'package:pakgo/features/home/screen/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  // This child will be the page the navigator wants to show.
  final Widget? child;

  const AuthWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // This logic remains the same for auto-login
        if (userProvider.status == AuthStatus.Uninitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.tryAutoLogin(context);
          });
        }

        switch (userProvider.status) {
          case AuthStatus.Unauthenticated:
          // If logged out, ALWAYS show the LoginScreen, ignoring the child.
            return const LoginScreen();

          case AuthStatus.Authenticated:
          // If logged in, show whatever page the navigator intended.
          // On first load, this will be the 'home' from MaterialApp.
          // On subsequent navigations, it will be the new page.
            return child ?? const HomeScreen(); // Fallback to HomeScreen if child is null

          case AuthStatus.Uninitialized:
          case AuthStatus.Authenticating:
          default:
          // Show a loading screen while figuring out the auth state.
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
        }
      },
    );
  }
}
