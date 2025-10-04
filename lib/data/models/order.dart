// lib/data/models/order.dart

// An enum for type-safe status handling, aligned with the UI's needs
enum OrderStatus {
  pending,
  inProgress,
  delivered,
  cancelled,
  unknown,
}

class Order {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final String consigneeName;
  final String dropAddress; // This corresponds to consigneeAddress
  final String pickupAddress;
  final DateTime createdAt;

  // ADDED: Latitude and Longitude fields
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;


  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.consigneeName,
    required this.dropAddress,
    required this.pickupAddress,
    required this.createdAt,
    // ADDED: Add new fields to the constructor
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
  });

  // Factory constructor to parse JSON from the API
  factory Order.fromJson(Map<String, dynamic> json) {
    // Assuming the backend DTO will contain these fields
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['orderNumber'] ?? 'N/A',
      status: _statusFromString(json['status'] ?? ''),
      consigneeName: json['consigneeName'] ?? 'Unknown',
      dropAddress: json['consigneeAddress'] ?? 'No address provided',
      pickupAddress: json['pickupAddress'] ?? 'No address provided',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

      // ADDED: Parse lat/lng from JSON with safety checks
      pickupLat: (json['pickupLat'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLng'] ?? 0.0).toDouble(),
      dropLat: (json['dropLat'] ?? 0.0).toDouble(),
      dropLng: (json['dropLng'] ?? 0.0).toDouble(),
    );
  }

  // UPDATED: Helper to convert status string from the Java backend to our enum
  static OrderStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return OrderStatus.pending;
      case 'ASSIGNED':
      case 'PICKED_UP':
        return OrderStatus.inProgress;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }
}