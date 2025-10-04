class OrderRequest {
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String consigneeName;
  final String consigneePhone;
  final String consigneeAddress;
  final String? specialInstructions;

  OrderRequest({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.consigneeName,
    required this.consigneePhone,
    required this.consigneeAddress,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'consigneeName': consigneeName,
      'consigneePhone': consigneePhone,
      'consigneeAddress': consigneeAddress,
    };

    if (specialInstructions != null) {
      data['specialInstructions'] = specialInstructions;
    }

    return data;
  }
}