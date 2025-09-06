import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pakgo/features/profile/screen/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  // ... (rest of the class is the same)
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // REMOVED: final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool _hasActiveOrder = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'User';

    return Scaffold(
      // REMOVED: key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Shiplyt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // CHANGED: Navigate to the new ProfileScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // REMOVED: endDrawer: const AppDrawer(),
      body: Padding(
        // ... (The rest of your HomeScreen body with the 4 cards remains exactly the same)
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          // ...
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                _ActionCard(
                  icon: Bootstrap.box_arrow_up,
                  title: "Send",
                  subtitle: "Create a new delivery",
                  onTap: () {},
                ),
                const SizedBox(width: 20),
                _ActionCard(
                  icon: Bootstrap.box_arrow_down,
                  title: "Receive",
                  subtitle: "Manage incoming items",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _ActionCard(
                  icon: Clarity.map_outline_badged,
                  title: "Track",
                  subtitle: "Track your orders",
                  onTap: () {},
                ),
                const SizedBox(width: 20),
                _ActionCard(
                  icon: Bootstrap.question_circle,
                  title: "Help",
                  subtitle: "Get support & FAQs",
                  onTap: () {},
                ),
              ],
            ),
            const Spacer(),
            if (_hasActiveOrder) const _ActiveOrderCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ... (_ActionCard and _ActiveOrderCard widgets remain unchanged)
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
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
              Icon(icon, size: 35, color: Colors.white),
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
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.white, size: 30),
            SizedBox(width: 15),
            Expanded(
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
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
