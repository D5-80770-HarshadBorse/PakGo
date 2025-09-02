import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pakgo/routes/app_routes.dart'; // Assuming you have this for navigation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // In a real app, this would be fetched from a service or state management solution
  final String userName = "User";
  final bool _hasActiveOrder = true; // Set to true to see the active order card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PakGo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to the user's profile screen
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- Welcome Message ---
            Text(
              "Hello, $userName!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "What would you like to do today?",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),

            // --- Action Cards: Send & Receive ---
            Row(
              children: [
                _buildActionCard(
                  context: context,
                  icon: Bootstrap.box_seam,
                  title: "Send",
                  subtitle: "Create a new delivery",
                  onTap: () {
                    // TODO: Navigate to the screen for creating a new order
                    // Navigator.pushNamed(context, AppRoutes.createOrder);
                  },
                ),
                const SizedBox(width: 20),
                _buildActionCard(
                  context: context,
                  icon: Bootstrap.truck,
                  title: "Receive",
                  subtitle: "Track your orders",
                  onTap: () {
                    // TODO: Navigate to the order history or tracking screen
                    // Navigator.pushNamed(context, AppRoutes.orderTracking);
                  },
                ),
              ],
            ),

            const Spacer(), // Pushes the active order card to the bottom

            // --- Active Order Status Card (Conditional) ---
            if (_hasActiveOrder) _buildActiveOrderCard(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // A reusable widget for the main action cards
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A widget to show the status of the current active order
  Widget _buildActiveOrderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Order is on the Way!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tap to see live location",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }
}
