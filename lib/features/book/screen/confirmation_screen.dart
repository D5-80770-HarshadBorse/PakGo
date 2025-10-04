import 'package:flutter/material.dart';
import 'package:pakgo/data/models/order_request.dart';
import 'package:pakgo/data/providers/booking_provider.dart';
import 'package:pakgo/features/book/services/order_service.dart';
import 'package:pakgo/routes/app_routes.dart';
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // 2. Get location data from Provider
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Safety check, though we shouldn't get here without this data
    if (bookingProvider.pickupLocation == null || bookingProvider.dropoffLocation == null) {
      _showDialog("Error", "Location data is missing. Please go back and select locations.");
      setState(() => _isLoading = false);
      return;
    }

    // 3. Create the OrderRequest object
    final orderRequest = OrderRequest(
      pickupLat: bookingProvider.pickupLocation!.latitude,
      pickupLng: bookingProvider.pickupLocation!.longitude,
      dropLat: bookingProvider.dropoffLocation!.latitude,
      dropLng: bookingProvider.dropoffLocation!.longitude,
      consigneeName: _nameController.text,
      consigneePhone: _phoneController.text,
      consigneeAddress: _addressController.text,
      specialInstructions: _instructionsController.text.isNotEmpty
          ? _instructionsController.text
          : null,
    );

    // 4. Call the OrderService
    try {
      final result = await OrderService.createOrder(orderRequest: orderRequest);

      if (result['success']) {
        // Clear provider state for next booking
        bookingProvider.clearBooking();
        _showDialog(
          "Success",
          "Your order has been placed successfully!",
          isSuccess: true,
        );
      } else {
        _showDialog("Order Failed", result['message'] ?? 'An unknown error occurred.');
      }
    } catch (e) {
      _showDialog("Error", "An unexpected error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              if(isSuccess) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                      (Route<dynamic> route) => false,
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the data and rebuild when it changes
    return Consumer<BookingProvider>(
      builder: (context, booking, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Your Booking'),
            backgroundColor: Colors.grey[850],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Location Summary ---
                  _buildLocationSummaryTile(
                    icon: Icons.my_location,
                    title: 'Pickup',
                    subtitle: booking?.pickupAddress ?? 'Not set',
                  ),
                  const SizedBox(height: 8),
                  _buildLocationSummaryTile(
                    icon: Icons.location_on,
                    title: 'Drop-off',
                    subtitle: booking.dropoffAddress ?? 'Not set',
                  ),
                  const Divider(height: 32, thickness: 1),

                  // --- Consignee Details Form ---
                  Text(
                    'Consignee Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Consignee Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                    validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.comment),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // --- Submit Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SUBMIT ORDER', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationSummaryTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}