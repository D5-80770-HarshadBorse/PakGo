import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/widgets/ImageAssetMarker.dart';
import 'package:pakgo/core/widgets/PulsingLocationPin.dart';
import 'package:pakgo/data/providers/booking_provider.dart';
import 'package:pakgo/features/book/screen/confirmation_screen.dart';
import 'package:pakgo/features/book/services/location_service.dart';
import 'package:pakgo/routes/app_routes.dart';
import 'package:provider/provider.dart';

enum BookingState { loadingLocation, viewingMap, searchingAddress }

enum AddressField { pickup, dropoff }

class BookingLocation extends StatefulWidget {
  const BookingLocation({super.key});

  @override
  State<BookingLocation> createState() => _BookingLocationState();
}

class _BookingLocationState extends State<BookingLocation> {
  // --- Services and Controllers ---
  final LocationService _locationService =
      LocationService(); // NEW: Service instance
  final MapController _mapController = MapController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  Timer? _debounce;

  // --- State Variables ---
  BookingState _bookingState = BookingState.loadingLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<Map<String, dynamic>> _searchResults = [];
  List<LatLng> _routePoints = [];
  bool _isSearchingApi = false;
  bool _isRouteLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  // --- Helper to show errors ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- LOGIC METHODS (now cleaner) ---

  Future<void> _getCurrentLocation() async {
    try {
      // Permission logic remains the same
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw ('Location permissions denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw ('Permissions permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);
      // OPTIMIZED: Call the service for reverse geocoding
      final address = await _locationService.getAddressFromLatLng(
        currentLatLng,
      );

      setState(() {
        _pickupLocation = currentLatLng;
        _pickupController.text = address;
        _bookingState = BookingState.viewingMap;
      });
      _mapController.move(currentLatLng, 15.0);
    } catch (e) {
      _showErrorSnackBar("Error getting location: $e");
      setState(() {
        _pickupController.text = "Could not get location";
        _bookingState = BookingState.viewingMap;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Reduced debounce time slightly
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }
      setState(() => _isSearchingApi = true);
      try {
        // OPTIMIZED: Call the service for address search
        final results = await _locationService.searchAddress(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        if (mounted) setState(() => _isSearchingApi = false);
      }
    });
  }

  Future<void> _getRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    setState(() => _isRouteLoading = true);
    try {
      // OPTIMIZED: Call the service to get the route
      final newRoutePoints = await _locationService.getRoute(
        _pickupLocation!,
        _dropoffLocation!,
      );
      if (mounted) setState(() => _routePoints = newRoutePoints);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isRouteLoading = false);
    }
  }

  void _onSearchResultSelected(Map<String, dynamic> result) async {
    // OPTIMIZED: Hide keyboard for better UX
    FocusScope.of(context).unfocus();

    final lat = double.tryParse(result['lat'] ?? '');
    final lon = double.tryParse(result['lon'] ?? '');
    final displayName = result['display_name'] ?? 'Unknown Location';

    if (lat != null && lon != null) {
      setState(() {
        _dropoffLocation = LatLng(lat, lon);
        _dropoffController.text = displayName;
        _searchResults = [];
        _bookingState = BookingState.viewingMap;
      });

      await _getRoute();

      if (_pickupLocation != null && _dropoffLocation != null) {
        final bounds = LatLngBounds.fromPoints([
          _pickupLocation!,
          _dropoffLocation!,
        ]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    if (_pickupLocation != null) {
      markers.add(
        Marker(
          point: _pickupLocation!,
          width: 60,
          height: 60,
          child: const PulsingLocationPin(),
        ),
      );
    }
    if (_dropoffLocation != null) {
      markers.add(
        Marker(
          point: _dropoffLocation!,
          width: 50,
          height: 70,
          child: const ImageAssetMarker(
            assetPath: 'assets/images/dropoff_pin.png',
          ),
        ),
      );
    }
    return markers;
  }

  // --- BUILD METHOD & UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(33.6844, 73.0479),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConstants.stadiaTileUrl, // Using constant
                userAgentPackageName: 'com.pakgo.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      gradientColors: [
                        Colors.blue.shade300,
                        Colors.blue.shade700,
                      ],
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // --- UI PANELS ---
          // OPTIMIZED: UI is now built via methods that pass callbacks
          if (_bookingState == BookingState.searchingAddress)
            _buildSearchPanel()
          else
            _buildMapPanel(),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      _searchResults = [];
                      FocusScope.of(context).unfocus(); // Hide keyboard
                      setState(() => _bookingState = BookingState.viewingMap);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Set Destination",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _pickupController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Pickup location",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dropoffController,
                      autofocus: true,
                      onChanged: _searchAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Where to?",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              if (_isSearchingApi)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        title: Text(
                          result['display_name'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => _onSearchResultSelected(result),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPanel() {
    bool canConfirm =
        _pickupLocation != null &&
        _dropoffLocation != null &&
        _routePoints.isNotEmpty;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () =>
                  setState(() => _bookingState = BookingState.searchingAddress),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dropoffController.text.isEmpty
                            ? "Where to?"
                            : _dropoffController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm ? Colors.blueAccent : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: canConfirm
                  ? () {
                      final bookingProvider = Provider.of<BookingProvider>(
                        context,
                        listen: false,
                      );

                      bookingProvider.updatePickup(
                        _pickupLocation!,
                        _pickupController.text,
                      );
                      bookingProvider.updateDropoff(
                        _dropoffLocation!,
                        _dropoffController.text,
                      );

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.bookingConfirmation,
                      );
                    }
                  : null,
              child: _isRouteLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONFIRM BOOKING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
