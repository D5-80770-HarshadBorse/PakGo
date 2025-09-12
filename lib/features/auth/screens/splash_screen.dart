import 'package:flutter/material.dart';
import 'package:pakgo/core/constants/auth_status.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/login.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.status == AuthStatus.Uninitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.tryAutoLogin(context);
          });
        }
        switch (userProvider.status) {
          case AuthStatus.Uninitialized:
          case AuthStatus.Authenticating:
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          case AuthStatus.Authenticated:
            return const HomeScreen();
          case AuthStatus.Unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
