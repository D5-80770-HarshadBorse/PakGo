import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class BookingProvider with ChangeNotifier {
  LatLng? _pickupLocation;
  String? _pickupAddress;
  LatLng? _dropoffLocation;
  String? _dropoffAddress;

  // Public getters to access the state
  LatLng? get pickupLocation => _pickupLocation;
  String? get pickupAddress => _pickupAddress;
  LatLng? get dropoffLocation => _dropoffLocation;
  String? get dropoffAddress => _dropoffAddress;

  void updatePickup(LatLng location, String address) {
    _pickupLocation = location;
    _pickupAddress = address;
    notifyListeners();
  }

  void updateDropoff(LatLng location, String address) {
    _dropoffLocation = location;
    _dropoffAddress = address;
    notifyListeners();
  }

  // To be called after a booking is complete
  void clearBooking() {
    _pickupLocation = null;
    _pickupAddress = null;
    _dropoffLocation = null;
    _dropoffAddress = null;
    notifyListeners();
  }
}