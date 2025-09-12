import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakgo/core/utils/locator.dart';
import 'package:pakgo/core/utils/navigation_service.dart';
import 'package:pakgo/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';
import 'package:pakgo/features/auth/screens/auth_wrapper.dart';
import 'package:pakgo/features/home/screen/home_screen.dart';

void main() {
  // Initialize the service locator before running the app
  setupLocator();
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

        // Use the navigatorKey from our NavigationService
        navigatorKey: locator<NavigationService>().navigatorKey,

        home: const AuthWrapper(),
        onGenerateRoute: AppRoutesInitializer.generateRoute,
      ),
    );
  }
}
