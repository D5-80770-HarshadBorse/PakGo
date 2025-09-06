import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/splash_screen.dart';
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
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DeliveryAppLogin',
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
        home: const SplashScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

