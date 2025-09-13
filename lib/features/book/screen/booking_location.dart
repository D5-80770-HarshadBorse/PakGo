import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class BookingLocation extends StatefulWidget {
  const BookingLocation({super.key});

  @override
  State<BookingLocation> createState() => _BookingLocationState();
}

class _BookingLocationState extends State<BookingLocation> {
  final MapController _mapController = MapController();

  // A timer to prevent sending too many requests to the Nominatim API
  Timer? _debounce;

  // --- State Variables ---
  String _pickupAddress = "Getting your location...";
  LatLng? _pickupLocation;

  String _dropoffAddress = "Select drop-off on the map";
  LatLng? _dropoffLocation;

  bool _isSettingDropoff = false;
  bool _isLoadingLocation = true; // For the initial GPS fetch
  bool _isUpdatingDropoff = false; // For map-drag updates

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    // Clean up the timer when the widget is disposed.
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSettingDropoff ? 'Select Drop-off' : 'Confirm Pickup'),
        backgroundColor: Colors.black, // Matching your theme
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // --- Flutter Map Widget ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.6844, 73.0479), // Default center
              initialZoom: 14.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isSettingDropoff) {
                  _updateDropoffAddressFromMapCenter(position);
                }
              },
            ),
            children: [
              // Layer 1: The map tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pakgo.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),

              // Layer 2: The current location marker (NEWLY ADDED)
              // This layer will only build if _pickupLocation is not null.
              if (_pickupLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      // Use the _pickupLocation from our state
                      point: _pickupLocation!,
                      width: 80,
                      height: 80,
                      // The widget that will be the pin
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // --- Center Pin (only visible for drop-off) ---
          // This remains on top of the map layers
          if (_isSettingDropoff)
            const Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 50,
              ),
            ),

          // --- UI Panel at the bottom ---
          _buildLocationPanel(),
        ],
      ),
    );
  }


  Widget _buildLocationPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddressRow(
                icon: Icons.my_location,
                color: Colors.blue,
                label: "PICKUP",
                address: _pickupAddress,
                isLoading: _isLoadingLocation,
                onTap: _getCurrentLocation,
              ),
              const Divider(height: 24),
              _buildAddressRow(
                icon: Icons.location_on,
                color: Colors.red,
                label: "DROP-OFF",
                address: _dropoffAddress,
                isLoading: _isUpdatingDropoff,
                onTap: _pickupLocation == null ? null : () {
                  setState(() {
                    _isSettingDropoff = true;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (_pickupLocation != null && _dropoffLocation != null)
                    ? () {
                  Navigator.of(context).pop({
                    'pickup': {'address': _pickupAddress, 'location': _pickupLocation},
                    'dropoff': {'address': _dropoffAddress, 'location': _dropoffLocation},
                  });
                }
                    : null,
                child: const Text('CONFIRM BOOKING'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color color,
    required String label,
    required String address,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                if (isLoading)
                  const LinearProgressIndicator()
                else
                  Text(address, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          if (onTap != null && !isLoading) const Icon(Icons.refresh, color: Colors.grey),
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---

  Future<String> _getAddressFromLatLngOSM(LatLng position) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {'User-Agent': 'com.pakgo.app'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? "Unknown Location";
      }
      return "Could not fetch address";
    } catch (e) {
      return "Error: Please check connection";
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _pickupAddress = "Getting your location...";
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw ('Location permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) throw ('Location permissions are permanently denied');

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final currentLatLng = LatLng(position.latitude, position.longitude);

      final address = await _getAddressFromLatLngOSM(currentLatLng);

      setState(() {
        _pickupLocation = currentLatLng;
        _pickupAddress = address;
        // Also set the initial drop-off location to the current one
        _dropoffLocation = currentLatLng;
        _dropoffAddress = address;
      });

      _mapController.move(currentLatLng, 16.0);
    } catch (e) {
      setState(() {
        _pickupAddress = "Could not get location";
      });
      print("Error getting location: $e");
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _updateDropoffAddressFromMapCenter(MapPosition position) {
    // If a debounce timer is already running, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new timer to run after 800ms
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return; // Check if the widget is still in the tree

      setState(() {
        _isUpdatingDropoff = true;
      });

      final centerPosition = position.center;
      if (centerPosition != null) {
        final address = await _getAddressFromLatLngOSM(centerPosition);
        if (mounted) {
          setState(() {
            _dropoffLocation = centerPosition;
            _dropoffAddress = address;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isUpdatingDropoff = false;
        });
      }
    });
  }
}
