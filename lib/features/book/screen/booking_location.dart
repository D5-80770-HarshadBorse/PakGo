import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:pakgo/core/widgets/CustomMarker.dart';
import 'package:pakgo/core/widgets/ImageAssetMarker.dart';
import 'package:pakgo/core/widgets/PulsingLocationPin.dart';

enum BookingState { loadingLocation, viewingMap, searchingAddress }

enum AddressField { pickup, dropoff }

class BookingLocation extends StatefulWidget {
  const BookingLocation({super.key});

  @override
  State<BookingLocation> createState() => _BookingLocationState();
}

class _BookingLocationState extends State<BookingLocation> {
  final MapController _mapController = MapController();
  Timer? _debounce;

  // --- Controllers for Search ---
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  // --- State Variables ---
  BookingState _bookingState = BookingState.loadingLocation;
  AddressField? _editingField;

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchingApi = false;
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;

  final String _stadiaApiKey =
      'eef70c63-704f-42a5-bfdf-97387be69aa1'; // PASTE YOUR KEY HERE

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

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- MAP ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.6844, 73.0479),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$_stadiaApiKey',
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

          // --- UI PANELS (conditionally shown) ---
          if (_bookingState == BookingState.searchingAddress)
            _buildSearchPanel()
          else
            _buildMapPanel(),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

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
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      _searchResults = [];
                      _dropoffController.clear();
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
                    _buildSearchTextField(
                      controller: _pickupController,
                      hint: "Pickup location",
                      isPickup: true,
                    ),
                    const SizedBox(height: 8),
                    _buildSearchTextField(
                      controller: _dropoffController,
                      hint: "Where to?",
                      isPickup: false,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              // --- Autocomplete Results ---
              if (_isSearchingApi)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
              // --- Option to select on map ---
              ListTile(
                leading: const Icon(Icons.map, color: Colors.white),
                title: const Text(
                  "Select location on map",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // This is how you allow editing/cancelling
                  _searchResults = [];
                  setState(() => _bookingState = BookingState.viewingMap);
                  // The UI will now show the map with a center pin for dropoff selection
                  // You would need to implement the center pin logic again if desired
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildSearchTextField({
    required TextEditingController controller,
    required String hint,
    required bool isPickup,
  }) {
    return TextField(
      controller: controller,
      readOnly: isPickup, // Make pickup read-only for now
      autofocus: !isPickup,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
        prefixIcon: Icon(
          isPickup ? Icons.my_location : Icons.search,
          color: Colors.white,
        ),
      ),
      onChanged: (query) {
        if (query.isNotEmpty) {
          _searchAddress(query);
        } else {
          setState(() => _searchResults = []);
        }
      },
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
              onTap: () {
                _editingField = AddressField.dropoff;
                setState(() => _bookingState = BookingState.searchingAddress);
              },
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
                    Text(
                      _dropoffController.text.isEmpty
                          ? "Where to?"
                          : _dropoffController.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                      /* Handle booking */
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

  // In lib/features/location/screens/booking_location_osm_screen.dart

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    if (_pickupLocation != null) {
      markers.add(
        Marker(
          point: _pickupLocation!,
          width: 60,
          height: 60,
          child: const PulsingLocationPin(), // This one stays the same
        ),
      );
    }

    // --- THIS IS THE SECTION TO CHANGE ---
    if (_dropoffLocation != null) {
      markers.add(
        Marker(
          point: _dropoffLocation!,
          // Adjust size for the pin's shape (taller than it is wide)
          width: 50,
          height: 70,
          child: const ImageAssetMarker(
            assetPath: 'assets/images/dropoff_pin.png',
          ),
        ),
      );
    }
    // --- END OF CHANGE ---

    return markers;
  }

  // --- LOGIC METHODS ---

  void _onSearchResultSelected(Map<String, dynamic> result) async {
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

      // Zoom map to fit both points
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

  Future<void> _searchAddress(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      setState(() => _isSearchingApi = true);
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'com.pakgo.app'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          if (mounted) {
            setState(() => _searchResults = data.cast<Map<String, dynamic>>());
          }
        }
      } catch (e) {
        print("Search error: $e");
      } finally {
        if (mounted) setState(() => _isSearchingApi = false);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _bookingState = BookingState.loadingLocation);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw ('Location permissions denied');
      }
      if (permission == LocationPermission.deniedForever)
        throw ('Permissions permanently denied');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);
      final address = await _getAddressFromLatLngOSM(currentLatLng);
      setState(() {
        _pickupLocation = currentLatLng;
        _pickupController.text = address;
        _bookingState = BookingState.viewingMap;
      });
      _mapController.move(currentLatLng, 15.0);
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _pickupController.text = "Could not get location";
        _bookingState = BookingState.viewingMap;
      });
    }
  }

  Future<void> _getRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;
    setState(() => _isRouteLoading = true);
    try {
      final pickupLon = _pickupLocation!.longitude;
      final pickupLat = _pickupLocation!.latitude;
      final dropoffLon = _dropoffLocation!.longitude;
      final dropoffLat = _dropoffLocation!.latitude;
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$pickupLon,$pickupLat;$dropoffLon,$dropoffLat?overview=full&geometries=geojson',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry']['coordinates'];
        final newRoutePoints = geometry
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
        if (mounted) setState(() => _routePoints = newRoutePoints);
      }
    } catch (e) {
      print('Error fetching route: $e');
    } finally {
      if (mounted) setState(() => _isRouteLoading = false);
    }
  }

  Future<String> _getAddressFromLatLngOSM(LatLng position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'com.pakgo.app'},
    );
    return response.statusCode == 200
        ? json.decode(response.body)['display_name'] ?? "Unknown"
        : "Error";
  }
}
