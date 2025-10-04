// lib/features/tracking/screen/tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pakgo/data/models/order.dart';
import 'package:pakgo/data/providers/order_provider.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch orders when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchUserOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.orders.isEmpty) {
            return const Center(child: Text('You have no orders yet.'));
          }

          final activeOrders = provider.orders
              .where((o) =>
          o.status == OrderStatus.inProgress ||
              o.status == OrderStatus.pending)
              .toList();

          final completedOrders = provider.orders
              .where((o) => o.status == OrderStatus.delivered)
              .toList();

          final cancelledOrders = provider.orders
              .where((o) => o.status == OrderStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrderListView(orders: activeOrders, emptyMessage: 'No active orders.'),
              _OrderListView(orders: completedOrders, emptyMessage: 'No completed orders.'),
              _OrderListView(orders: cancelledOrders, emptyMessage: 'No cancelled orders.'),
            ],
          );
        },
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final List<Order> orders;
  final String emptyMessage;
  const _OrderListView({required this.orders, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index]);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(
                icon: Icons.person,
                label: 'Recipient',
                value: order.consigneeName),
            const SizedBox(height: 8),
            _InfoRow(
                icon: Icons.location_on,
                label: 'From',
                value: order.pickupAddress),
            const SizedBox(height: 8),
            _InfoRow(
                icon: Icons.flag,
                label: 'To',
                value: order.dropAddress),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Placed on: ${DateFormat.yMMMd().format(order.createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}


class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case OrderStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}