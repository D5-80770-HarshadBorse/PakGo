import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakgo/core/constants/auth_status.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/login.dart';
import 'package:pakgo/features/auth/screens/splash_screen.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/routes/app_routes.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // The UserProvider now starts with AuthStatus.Uninitialized
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DeliveryAppLogin',
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
        // The AuthCheck widget is still our home, but its logic is now correct
        home: const SplashScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

