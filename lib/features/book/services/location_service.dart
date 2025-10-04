import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pakgo/core/constants/api_constants.dart';

class LocationService {
  final _headers = {'User-Agent': 'com.pakgo.app'};

  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      final url = Uri.parse(ApiConstants.osmSearchUrl(query));
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      throw 'Failed to search address';
    } catch (e) {
      // Re-throw to be caught in the UI layer for user feedback
      throw Exception('Search error: $e');
    }
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      final url = Uri.parse(
          ApiConstants.osmReverseGeocodeUrl(position.latitude, position.longitude));
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body)['display_name'] ?? "Unknown Location";
      }
      return "Could not fetch address";
    } catch (e) {
      print("Reverse geocode error: $e");
      return "Error getting address";
    }
  }

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(ApiConstants.osrmRouteUrl(
        start.longitude, start.latitude, end.longitude, end.latitude,
      ));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry']['coordinates'];
        return geometry
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      }
      throw 'Failed to fetch route';
    } catch (e) {
      throw Exception('Error fetching route: $e');
    }
  }
}