import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Assuming you use this
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/auth_wrapper.dart'; // Import the new wrapper
import 'package:pakgo/features/home/screen/home_screen.dart';   // Import home screen
// import 'package:pakgo/routes.dart'; // Assuming you have this file for onGenerateRoute

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DeliveryAppLogin',
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),

        // The builder acts as a persistent wrapper around the navigator.
        builder: (context, child) {
          return AuthWrapper(child: child);
        },

        // 'home' is now the default page to show when authenticated.
        home: const HomeScreen(),

        // Your onGenerateRoute will continue to work perfectly.
        // onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
