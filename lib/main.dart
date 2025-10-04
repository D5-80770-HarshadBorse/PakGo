import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakgo/data/providers/booking_provider.dart';
import 'package:pakgo/data/providers/order_provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/routes/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Recommendation #2: Use MultiProvider for scalability
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider())
        // Add other global providers here in the future
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PakGo Delivery', // A more descriptive title
        theme: ThemeData(
          // Using a seed color is a modern way to generate a full color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
        ),

        // Recommendation #1: Unify route handling
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

