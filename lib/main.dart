import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakgo/routes/app_routes.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery App Login',
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
